#!/bin/bash

# Change .md links to .html
perl -pi -e 's:\.md\):.html\):' branches/*/docs/*.md

# Change .raml links to .html, also different dir
perl -pi -e 's:APIs/(.*)\.raml\):html-APIs/$1.html\):' branches/*/docs/*.md

