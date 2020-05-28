# AMWA IS-04 NMOS Discovery and Registration Specification

This repository contains details of this AMWA Specification, including Node, Registration and Query APIs, and requirements for Nodes for registry-based and peer-to-peer discovery. with supporting documentation and examples

## Getting started

Readers are advised to be familiar with:
* The [JT-NM Reference Architecture](http://jt-nm.org/RA-1.0/)
* The [overview of Networked Media Open Specifications](https://github.com/AMWA-TV/nmos)

Readers should then read the [documentation](docs/), [APIs](APIs/) (RAML and JSON Schema), and [examples](examples/) (JSON) 

> HTML rendered versions of all NMOS Specifications are available on the [NMOS GitHub pages](https://amwa-tv.github.io/nmos)

## Releases

It is recommended that the tagged releases are used as a reference for development as opposed to the 'master' or development branches of this repository.

Each version of the specification is available under a v&lt;#MAJOR&gt;.&lt;#MINOR&gt; tag such as 'v1.0'. Once a specification has been released, any updates to its documentation and schemas which do not modify the specification will be made available via a v&lt;#MAJOR&gt;.&lt;#MINOR&gt;.&lt;#UPDATE&gt; tag such as 'v1.0.1'.

## Contents

* README.md -- This file
* [docs/1.0. Overview.md](docs/1.0.%20Overview.md) -- Documentation targeting those implementing APIs and clients. Further topics are covered within the [docs/](docs/) directory
* [APIs/NodeAPI.raml](APIs/NodeAPI.raml) -- Normative specification of the NMOS Node API
* [APIs/RegistrationAPI.raml](APIs/RegistrationAPI.raml) -- Normative specification of the NMOS Registration API
* [APIs/QueryAPI.raml](APIs/QueryAPI.raml) -- Normative specification of the NMOS Query API
* [APIs/schemas/](APIs/schemas/) -- JSON schemas used by API specifications
* [APIs/generateHTML](APIs/generateHTML) -- Tool to create HTML browsable version of the API specifications. Requires [raml2html](https://github.com/kevinrenskers/raml2html).
* [examples/](examples/) -- Example JSON requests and responses for APIs
* [LICENSE](LICENSE) -- Licenses for software and text documents
* [NOTICE](NOTICE) -- Disclaimer
