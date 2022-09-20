#!/bin/sh

set -e

rm -rf repos
mkdir repos
rm -rf Buildpacks
git clone git@git.hubteam.com:HubSpotProtected/Buildpacks.git > /dev/null 2>&1

cat to-migrate.txt | while read line; do
    host=$(echo $line | awk '{print $1}')
    org=$(echo $line | awk '{print $2}')
    repo=$(echo $line | awk '{print $3}')
    path=$(echo $line | awk '{print $4}')

    # if [ -z "${path}" ]; then
    #     path=$(echo $repo | gsed 's/Blazar-Buildpack-//I' | gsed 's/ios/ios/I' |  gsed -r 's/([a-z0-9])([A-Z])/\1_\L\2/g' | gsed s/_/-/g | awk '{print tolower($0)}')
    # fi
    # echo "$host $org $repo $path"
    # continue

    cd repos
    git clone git@$host:$org/$repo.git > /dev/null 2>&1
    cd $repo
    git fetch --all > /dev/null 2>&1

    default_branch=$(git rev-parse --abbrev-ref HEAD)
    default_buildpack_location=$(find . -name .blazar-buildpack.yaml -type f)
    default_buildpack_sha=$(sha1sum $default_buildpack_location | awk '{print $1}')
    buildpack_repo_dir="../../Buildpacks"

    rm -rf $buildpack_repo_dir/$path
    mkdir -p $buildpack_repo_dir/$path

    if [[ "$default_branch" == "master" || "$default_branch" == "main" ]]; then
        echo "Copying $default_buildpack_location to $buildpack_repo_dir/$path"
        mkdir -p $buildpack_repo_dir/$path
        cp $default_buildpack_location $buildpack_repo_dir/$path/.blazar-buildpack.yaml
    else
        echo "Copying $default_buildpack_location to $buildpack_repo_dir/$path/$branch"
        mkdir -p $buildpack_repo_dir/$path/$branch
        cp $default_buildpack_location $buildpack_repo_dir/$path/$branch/.blazar-buildpack.yaml
    fi

    if [[ "$repo" == "Blazar-Buildpack-Java" ]]; then
        for branch in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin/); do
            if [[ "$branch" == "origin/$default_branch" || "$branch" == "origin/master" ]]; then
                continue
            fi
            git checkout $branch > /dev/null 2>&1
            branch=$(echo $branch | sed s/origin\\///g)
            buildpack_location=$(find . -name .blazar-buildpack.yaml -type f)
            if [ -z "${buildpack_location}" ]; then
                echo "No buildpack $repo/$branch on branch, skipped"
                continue
            fi

            buildpack_sha=$(sha1sum $buildpack_location | awk '{print $1}')

            if [[ "$buildpack_sha" != "$default_buildpack_sha" ]]; then
                echo "Copying $buildpack_location to $buildpack_repo_dir/$path/$branch"
                mkdir -p $buildpack_repo_dir/$path/$branch
                cp $buildpack_location $buildpack_repo_dir/$path/$branch/.blazar-buildpack.yaml
            else
                echo "$repo/$branch is same as main, skipped"
            fi
        done
    fi
    cd ../..
done
echo "JOB COMPLETED WITH SUCCESS"