#!/bin/bash

# TODO: Move some of the common code into functions (DRY)

# Filename for all READMEs
README=README.md

for b_or_t in branches tags; do
    echo "Processing $b_or_t $README..."
    cd $b_or_t
    for dir in */; do
        dirname=${dir%%/}
        echo "Making $dirname/$README"
        cd $dir
            echo -e "# Documentation for $dirname\n" > "$README"
            for doc in docs/[1-9]*.md; do
                no_ext=${doc%%.md}
                # Top level documents have numbers ending in '.0'
                match_top_level='^docs/[1-9][0-9]*\.0\. '
                if [[ $doc =~ $match_top_level ]]; then
                    linktext=${no_ext#* }
                    echo " - [$linktext]($doc)" >> "$README"
                else
                    # Removing the top-level part of lower-level link texts
                    # that is the part up to the hyphen and following space
                    linktext=${no_ext#* - }
                    echo "   - [$linktext]($doc)" >> "$README"
                fi
            done

            README_APIS="html-APIs/$README"
            echo -e "\n## APIs" >> "$README"
            echo -e "# APIs for $dirname\n" > "$README_APIS"
            for api in html-APIs/*.html; do
                no_ext=${api%%.html}
                linktext=${no_ext##*/}
                echo " - [$linktext]($api)" >> "$README"
                echo " - [$linktext]($api)" >> "$README_APIS"
            done

            README_SCHEMAS="html-APIs/schemas/$README"
            echo -e "\n### [JSON Schemas](html-APIs/schemas/)" >> "$README"
            echo -e "## JSON Schemas\n" > "$README_SCHEMAS"
            for schema in html-APIs/schemas/*.json; do
                no_ext=${schema%%.json}
                linktext=${no_ext##*/}
                echo " - [$linktext](${schema##*/})" >> "$README_SCHEMAS"
            done

            README_EXAMPLES="examples/$README"
            echo -e "\n### [Examples](examples/)" >> "$README"
            echo -e "## Examples\n" > "$README_EXAMPLES"
            for example in examples/*.json; do
                no_ext=${example%%.json}
                linktext=${no_ext##*/}
                echo " - [$linktext](${example##*/})" >> "$README_EXAMPLES"
            done

            cd ..
    done
    cd ..
done

HEAD=README-head.md
CONTENTS=README-contents.md

echo "Making top level $README"

echo "Adding in contents of master $README"
# Shameful but effective - correct the links while copying text
sed 's:(:(branches/master/:' branches/master/$README > "$CONTENTS"

echo -e "\n## Branches" >> "$CONTENTS"
for dir in branches/*; do
    branch=${dir##*/}
    echo -e "\n[$branch](branches/$branch/)" >>  "$CONTENTS"
done

echo -e "\n## Tags" >> "$CONTENTS"
for dir in tags/*; do
    tag=${dir##*/}
    echo -e "\n[$tag](tags/$tag/)" >>  "$CONTENTS"
done
echo >> "$CONTENTS"


cat "$HEAD" "$CONTENTS" > "$README"
