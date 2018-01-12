#!/bin/bash

shopt -s nullglob

echo "Fixing links in documents"

for file in {branches,tags}/*/docs/*.md; do

    # Change .raml links to .html and rename APIs folder
    perl -pi -e 's:\.raml\):.html\):g; s:/APIs/:/html-APIs/:g;' $file

    # Change %20 escaped spaces in links to understores
    perl -ni -e '@parts = split /(\(.*?\.md\))/ ; for ($n = 1; $n < @parts; $n += 2) { $parts[$n] =~ s/%20/_/g; }; print @parts' $file

    # Same but for reference links
    perl -ni -e '@parts = split /(\]:.*?\.md)/ ; for ($n = 1; $n < @parts; $n += 2) { $parts[$n] =~ s/%20/_/g; }; print @parts' $file
done
