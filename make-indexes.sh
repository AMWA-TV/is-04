#!/bin/bash

# TODO: Move some of the common code into functions (DRY)

shopt -s nullglob

# Filename for index in each dir
INDEX=index.md

for b_or_t in branches tags; do
    echo "Processing $b_or_t $INDEX..."
    cd "$b_or_t"
    for dir in */; do
        dirname="${dir%%/}"
        echo "Making $dirname/$INDEX"
        cd "$dir"
            echo -e "# Documentation for $dirname\n" > "$INDEX"
            for doc in docs/[1-9]*.md; do
                no_ext="${doc%%.md}"
                # Spaces causing problems so rename extracted docs to use underscore
                underscore_space_doc="${doc// /_}"
                mv "$doc" "$underscore_space_doc"

                # Top level documents have numbers ending in '.0'
                match_top_level='^docs/[1-9][0-9]*\.0\. '
                if [[ "$doc" =~ $match_top_level ]]; then
                    linktext="${no_ext#* }"
                    echo " - [$linktext]($underscore_space_doc)" >> "$INDEX"
                else
                    # Removing the top-level part of lower-level link texts
                    # that is the part up to the hyphen and following space
                    linktext="${no_ext#* - }"
                    echo "   - [$linktext]($underscore_space_doc)" >> "$INDEX"
                fi
            done

            INDEX_APIS="html-APIs/$INDEX"
            echo -e "\n## APIs for $dirname" >> "$INDEX"
            echo -e "# APIs for $dirname\n" > "$INDEX_APIS"
            for api in html-APIs/*.html; do
                no_ext="${api%%.html}"
                linktext="${no_ext##*/}"
                echo " - [$linktext]($api)" | tee -a "$INDEX" >> "$INDEX_APIS"
            done

            INDEX_SCHEMAS="html-APIs/schemas/$INDEX"
            echo -e "\n### [JSON Schemas](html-APIs/schemas/)" >> "$INDEX"
            echo -e "## JSON Schemas\n" > "$INDEX_SCHEMAS"
            for schema in html-APIs/schemas/*.json; do
                no_ext="${schema%%.json}"
                linktext="${no_ext##*/}"
                echo " - [$linktext](${schema##*/})" >> "$INDEX_SCHEMAS"
            done

            INDEX_EXAMPLES="examples/$INDEX"
            echo -e "\n### [Examples](examples/)" >> "$INDEX"
            echo -e "## Examples\n" > "$INDEX_EXAMPLES"
            for example in examples/*.json; do
                no_ext="${example%%.json}"
                linktext="${no_ext##*/}"
                echo " - [$linktext](${example##*/})" >> "$INDEX_EXAMPLES"
            done

            cd ..
    done
    cd ..
done

HEAD=index-head.md
CONTENTS=index-contents.md

echo "Making top level $INDEX"

echo "Adding in contents of master $INDEX"
# Shameful but effective - correct the links while copying text
sed 's:(:(branches/master/:' "branches/master/$INDEX" > "$CONTENTS"

echo -e "\n## Branches" >> "$CONTENTS"
for dir in branches/*; do
    branch="${dir##*/}"
    echo -e "\n[$branch](branches/$branch/)" >>  "$CONTENTS"
done

echo -e "\n## Tags" >> "$CONTENTS"
for dir in tags/*; do
    tag="${dir##*/}"
    echo -e "\n[$tag](tags/$tag/)" >>  "$CONTENTS"
done
echo >> "$CONTENTS"


cat "$HEAD" "$CONTENTS" > "$INDEX"
