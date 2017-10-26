#!/bin/bash

TOP_CONTENTS=README-contents.md

echo "Making top level README.md"

echo "## Branches" > $TOP_CONTENTS

for branch in branches/*; do
    echo -e "\n[$branch](branches/$branch)" >>  $TOP_CONTENTS
done

echo -e "\n## Releases\n\n_tbc_" >> $TOP_CONTENTS

cat README-head.md README-contents.md  >> README.md

echo "Processing branches..."
cd branches
for dir in */; do
    dirname=${dir%%/}
    README=README.md
    echo "Making $dirname/$README"
    cd $dir
    echo -e "# Documentation for $dirname\n" > $README
    for doc in [1-9]*.md; do
        doc_no_ext=${doc%%.md}
        # Top level documents have numbers ending in '.0'
        match_top_level='^[1-9][0-9]*\.0\. '
        if [[ $doc =~ $match_top_level ]]; then
            linktext=${doc_no_ext#* } 
            echo " - [$linktext]($doc)" >> $README
        else
            # Removing the top-level part of lower-level link texts
            # that is the part up to the hyphen and following space
            linktext=${doc_no_ext#* - }
            echo "   - [$linktext]($doc)" >> $README
        fi
    done
    echo -e "\n[API documentation (rendered from RAML)](html-APIs)\n" >> $README
    cd ..
done
