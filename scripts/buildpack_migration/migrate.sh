#!/bin/sh

rm -rf repos
mkdir repos
rm -rf Buildpacks
git clone git@git.hubteam.com:HubSpotProtected/Buildpacks.git > /dev/null 2>&1

cat to-migrate.txt | while read line; do
    echo $line
    host=$(echo $line | awk '{print $1}')
    org=$(echo $line | awk '{print $2}')
    repo=$(echo $line | awk '{print $3}')
    path=$(echo $line | awk '{print $4}')

    cd repos
    git clone git@$host:$org/$repo.git > /dev/null 2>&1
    cd $repo

    default_branch=$(git rev-parse --abbrev-ref HEAD)
    default_buildpack_location=$(find . -name .blazar-buildpack.yaml -type f)
    default_buildpack_sha=$(sha1sum $default_buildpack_location | awk '{print $1}')
    buildpack_repo_dir="../../Buildpacks"

    rm -rf $buildpack_repo_dir/$path
    mkdir $buildpack_repo_dir/$path

    # avoid using master and swap to main
    if [[ "$default_branch" == "master" ]]; then
        branch="main"
    else
        branch=$default_branch
    fi

    echo "Copying $default_buildpack_location to $buildpack_repo_dir/$path/$branch"
    mkdir $buildpack_repo_dir/$path/$branch
    cp $default_buildpack_location $buildpack_repo_dir/$path/$branch/.blazar-buildpack.yaml

    for branch in $(git branch); do
        if [[ "$branch" == "$default_branch" ]]; then
            continue
        fi

        buildpack_location=$(find . -name .blazar-buildpack.yaml -type f)
        buildpack_sha=$(sha1sum $buildpack_location | awk '{print $1}')

        if [[ "$buildpack_sha" != "$default_buildpack_sha" ]]; then
            echo "Copying $buildpack_location to $buildpack_repo_dir/$path/$branch"
            mkdir $buildpack_repo_dir/$path/$branch
            cp $buildpack_location $buildpack_repo_dir/$path/$branch/.blazar-buildpack.yaml
        fi
    done
    cd ../..
done
