#!/bin/bash

git clone --no-checkout https://github.com/AMWA-TV/nmos-discovery-registration source-repo/

mkdir branches
for branch in $(cd source-repo; git branch -r | sed 's:origin/::' | grep -v HEAD | grep -v gh-pages); do
    echo "Extracting documentation from branch $branch..."
    mkdir branches/$branch
    cd source-repo
         git checkout $branch
         cp -r docs ../branches/$branch/
         cd APIs
            ./generateHTML
            mkdir ../../branches/$branch/html-APIs
            mv *.html ../../branches/$branch/html-APIs/
            cd ..
    cp -r examples ../branches/$branch
    cd ..
done

mkdir tags
for tag in $(cd source-repo; git tag); do
    echo "Extracting documentation for tag $tag..."
    mkdir tags/$tag
    cd source-repo
         git checkout tags/$tag
         cp -r docs ../tags/$tag/
         cd APIs
            ./generateHTML
            mkdir ../../tags/$tag/html-APIs
            mv *.html ../../tags/$tag/html-APIs/
            cd ..
    cp -r examples ../tags/$tag
    cd ..
done
