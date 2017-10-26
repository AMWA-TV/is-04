#!/bin/bash

# TODO: Split into functions to handle branches/tags and docs/APIs/examples (DRY)

HEAD=README-head.md
CONTENTS=README-contents.md
README=README.md

echo "Making top level README.md"

echo "## Branches" > $CONTENTS

for dir in branches/*; do
    branch=${dir##*/}
    echo -e "\n[$branch](branches/$branch)" >>  $CONTENTS
done
echo >> $CONTENTS

for dir in tags/*; do
    branch=${dir##*/}
    echo -e "\n[$tag](tags/$tag)" >>  $CONTENTS
done


cat $HEAD $CONTENTS > $README

for b_or_t in branches tags; do
    echo "Processing $b_or_t..."
    cd $b_or_t
    for dir in */; do
        dirname=${dir%%/}
        README=README.md
        echo "Making $dirname/$README"
        cd $dir
            echo -e "# Documentation for $dirname\n" > $README
            for doc in docs/[1-9]*.md; do
                no_ext=${doc%%.md}
                # Top level documents have numbers ending in '.0'
                match_top_level='^docs/[1-9][0-9]*\.0\. '
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

            README_APIS=html-APIs/README.md
            echo -e "# APIs for $dirname\n" > $README_APIS
            for api in html-APIs/*.html; do
                no_ext=${api%%.html}
                linktext=${no_ext#*/}
                echo " - [$linktext]($api)" >> $README_APIS
            done
            echo >> $README
            cat $README_APIS >> $README

            README_EXAMPLES=examples/README.md
            echo -e "# Examples for $dirname\n" > $README_EXAMPLES
            for example in examples/*.json; do
                no_ext=${example%%.json}
                linktext=${no_ext#*/}
                echo " - [$linktext]($example)" >> $README_EXAMPLES
            done
            echo >> $README
            cat $README_EXAMPLES >> $README

            cd ..
    done
    cd ..
done

