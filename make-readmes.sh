#!/bin/bash

TOP_CONTENTS=README-contents.md

echo "## Branches" > $TOP_CONTENTS

for branch in branches/*; do
  echo -e "\n[$branch]($branch)" >>  $TOP_CONTENTS
done

echo -e "\n## Releases\n\n_tbc_" >> $TOP_CONTENTS

cat README-head.md README-contents.md  >> README.md
