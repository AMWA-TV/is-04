# Generating the GitHub Pages documentation

Eventually this will be automated, but in the meantime, those with write access to the repo must update the GitHub Pages following any change to the specification or supporting documents.

Make sure you have the correct version for raml2html installed.  For RAML 0.8 you need v3.0:

``sudo npm install -g raml2html@3``

Clone this repo, checkout the gh-pages branch and make

``git clone https://github.com/AMWA-TV/nmos-discovery-registration``

``cd nmos-discovery-registration``

``git checkout gh-pages``

``make``

Check it's ok and if so push

``make push``
