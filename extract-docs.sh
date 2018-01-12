#!/bin/bash

function extract {
    checkout=$1
    target_dir=$2
    echo "Extracting documentation from $checkout into $target_dir"
    mkdir "$target_dir"
    cd source-repo
        git checkout "$checkout"
        cp -r docs "../$target_dir"
        cd APIs
            ##echo "NB: including workaround for how v6 of raml2html deals with \$ref and schemas/ dir"
            #perl -pi.orig -e 's=("\$ref": ")(.*)(\.json)=$1schemas/$2$3=' schemas/*.json
            ./generateHTML
            #for i in schemas/*.json.orig; do
            #    mv "$i" "${i%%.orig}"
            #done
            mkdir "../../$target_dir/html-APIs"
            mv *.html "../../$target_dir/html-APIs/"
            mkdir "../../$target_dir/html-APIs/schemas"
            cp schemas/*.json "../../$target_dir/html-APIs/schemas"
            cd ..
    cp -r examples "../$target_dir"
    cd ..

}


mkdir branches
for branch in $(cd source-repo; git branch -r | sed 's:origin/::' | grep -v HEAD | grep -v gh-pages); do
    extract "$branch" "branches/$branch"
done

mkdir tags
for tag in $(cd source-repo; git tag); do
    extract "tags/$tag" "tags/$tag"
done
