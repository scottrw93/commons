protoc-bundled-plugin
=====================

Maven Plugin Mojo for compiling Protobuf schema files. Protobuf compiler binaries for varions platforms and protobuf versions are bundled with the plugin and used as required.

### Available parameters

* binaryDirectory

    Directory for extracted helper binaries (protoc).

* inputDirectories

    Directories containing *.proto files to compile.

* outputDirectory

    Output directory for generated Java class files.

* protobufVersion

    Protobuf version to compile schema files for. If omitted, version is inferred from the project's depended-on `com.google.com:protobuf-java` artifact, if any. (If both are present, the version must match.)

* protocExec

   Path to existing protoc to use. Overrides auto-detection and use of bundled protoc.

### Minimal usage example

```xml
<plugins>
  ...
  <plugin>
    <groupId>com.comoyo.maven.plugins</groupId>
    <artifactId>protoc-bundled-plugin</artifactId>
    <version>1.0</version>
    <executions>
      <execution>
        <goals>
          <goal>run</goal>
        </goals>
      </execution>
    </executions>
  </plugin>
  ...
</plugins>
```
