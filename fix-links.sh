#!/bin/bash

perl -pi -e 's:APIs/(.*)\.raml:html-APIs/$1.html:' branches/*/docs/*.md

