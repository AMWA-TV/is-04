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
