#!/bin/bash

HEAD=README-head.md
CONTENTS=README-contents.md
README=README.md

echo "Making top level README.md"

echo "## Branches" > $CONTENTS

for dir in branches/*; do
    branch=${dir##*/}
    echo -e "\n[$branch](branches/$branch)" >>  $CONTENTS
done

echo -e "\n## Releases\n\n_tbc_" >> $CONTENTS

cat $HEAD $CONTENTS > $README

echo "Processing branches..."
cd branches
for dir in */; do
    dirname=${dir%%/}
    README=README.md
    echo "Making $dirname/$README"
    cd $dir
    echo -e "# Documentation for $dirname\n" > $README
    for doc in [1-9]*.md; do
        no_ext=${doc%%.md}
        # Top level documents have numbers ending in '.0'
        match_top_level='^[1-9][0-9]*\.0\. '
        if [[ $doc =~ $match_top_level ]]; then
            linktext=${no_ext#* } 
            echo " - [$linktext]($doc)" >> $README
        else
            # Removing the top-level part of lower-level link texts
            # that is the part up to the hyphen and following space
            linktext=${no_ext#* - }
            echo "   - [$linktext]($doc)" >> $README
        fi
    done

    echo -e "\n# APIs for $dirname" >> $README
    for api in html-APIs/*.html; do
        no_ext=${api%%.html}
        linktext=${no_ext#*/}
        echo " - [$linktext]($api)" >> $README
    done

    echo -e "\n# Examples for $dirname" >> $README
    for example in examples/*.json; do
        no_ext=${example%%.json}
        linktext=${no_ext#*/}
        echo " - [$linktext]($example)" >> $README
    done

    echo -e "\n[API documentation (rendered from RAML)](html-APIs)\n" >> $README
    cd ..
done

