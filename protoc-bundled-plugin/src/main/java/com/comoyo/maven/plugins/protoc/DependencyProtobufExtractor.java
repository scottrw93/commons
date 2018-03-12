package com.comoyo.maven.plugins.protoc;

import java.io.File;
import java.io.IOException;
import java.net.JarURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.maven.artifact.Artifact;
import org.apache.maven.artifact.DependencyResolutionRequiredException;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.SelectorUtils;
import org.reflections.Reflections;
import org.reflections.scanners.ResourcesScanner;
import org.reflections.util.ConfigurationBuilder;

import com.google.common.base.Predicate;

public class DependencyProtobufExtractor {
  private final MavenProject project;
  private final File outputDirectory;
  private final Collection<String> artifactPatterns;
  private final Log log;

  public DependencyProtobufExtractor(MavenProject project, File outputDirectory, Collection<String> artifactPatterns, Log log) {
    this.project = project;
    this.outputDirectory = outputDirectory;
    this.artifactPatterns = artifactPatterns;
    this.log = log;
  }

  public File[] extract() throws MojoExecutionException {
    final List<String> classpathElements;
    try {
      classpathElements = new ArrayList<>(project.getTestClasspathElements());
    } catch (DependencyResolutionRequiredException e) {
      throw new MojoExecutionException("Error resolving dependencies", e);
    }

    List<URL> urls = toUrls(classpathElements);
    Set<String> protos = findProtos(urls);

    return copyProtos(urls, outputDirectory.toPath(), protos);
  }

  private File[] copyProtos(
          List<URL> urls,
          Path outputDirectory,
          Set<String> protos
  ) throws MojoExecutionException {
    ClassLoader classLoader = URLClassLoader.newInstance(urls.toArray(new URL[urls.size()]));

    Map<String, Set<File>> orderedImportPaths = new LinkedHashMap<>();
    // initialize based on artifactPatterns collection so LinkedHashMap has the right iteration order
    for (String artifactPattern : artifactPatterns) {
      orderedImportPaths.put(artifactPattern, new LinkedHashSet<File>());
    }

    for (String proto : protos) {
      try {
        List<URL> protoUrls = Collections.list(classLoader.getResources(proto));
        if (protoUrls.isEmpty()) {
          throw new IllegalStateException("Proto " + proto + " seems to have disappeared?");
        }

        for (URL url : protoUrls) {
          URLConnection connection = url.openConnection();
          if (!(connection instanceof JarURLConnection)) {
            throw new MojoExecutionException("Expected proto to be in a JAR, invalid URL " + url);
          }
          File jar = new File(((JarURLConnection) connection).getJarFileURL().getFile());
          Artifact artifact = findArtifactWithFile(project.getArtifacts(), jar);
          if (artifact == null) {
            throw new MojoExecutionException("Unable to find artifact for JAR " + jar);
          }

          String matchedArtifactPattern = matchingPattern(artifact);
          if (matchedArtifactPattern == null) {
            log.debug("Skipping proto " + proto + " from artifact " + artifact + " because it doesn't match any patterns");
            continue;
          }

          Path target = outputDirectory;
          for (String part : artifact.getGroupId().split("\\.")) {
            target = target.resolve(part);
          }
          target = target.resolve(artifact.getArtifactId());
          orderedImportPaths.get(matchedArtifactPattern).add(target.toFile());
          target = target.resolve(proto);

          Files.createDirectories(target.getParent());
          Files.copy(url.openStream(), target, StandardCopyOption.REPLACE_EXISTING);
        }
      } catch (IOException e) {
        throw new MojoExecutionException("Error copying proto " + proto, e);
      }
    }

    List<File> flattenedImportPaths = new ArrayList<>();
    for (Set<File> artifactPatternImportPaths : orderedImportPaths.values()) {
      flattenedImportPaths.addAll(artifactPatternImportPaths);
    }
    return flattenedImportPaths.toArray(new File[flattenedImportPaths.size()]);
  }

  private String matchingPattern(Artifact artifact) {
    String artifactKey = artifact.getGroupId() + ":" + artifact.getArtifactId();
    for (String artifactPattern : artifactPatterns) {
      if (SelectorUtils.match(artifactPattern, artifactKey)) {
        return artifactPattern;
      }
    }
    return null;
  }

  private static List<URL> toUrls(List<String> paths) throws MojoExecutionException {
    List<File> files = presentFiles(paths);
    List<URL> urls = new ArrayList<>(files.size());
    for (File file : files) {
      try {
        urls.add(file.toURI().toURL());
      } catch (MalformedURLException e) {
        throw new MojoExecutionException("Error constructing classpath URLs", e);
      }
    }

    return urls;
  }

  private static Set<String> findProtos(List<URL> classpathElements) {
    Predicate<String> protoFile = new Predicate<String>() {

      @Override
      public boolean apply(String name) {
        return name != null && name.endsWith(".proto");
      }
    };

    ConfigurationBuilder configuration = new ConfigurationBuilder()
            .addUrls(classpathElements)
            .filterInputsBy(protoFile)
            .setScanners(new ResourcesScanner());
    return new Reflections(configuration).getResources(protoFile);
  }

  private static Artifact findArtifactWithFile(Set<Artifact> artifacts, File file) {
    for (Artifact artifact : artifacts) {
      if (file.equals(artifact.getFile())) {
        return artifact;
      }
    }

    return null;
  }

  private static List<File> presentFiles(List<String> paths) {
    List<File> files = new ArrayList<>();
    for (String path : paths) {
      File file = new File(path);
      if (file.getAbsoluteFile().isFile()) {
        files.add(file);
      }
    }

    return files;
  }

}
