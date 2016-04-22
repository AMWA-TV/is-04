# **[Proposed Specification]** AMWA NMOS Discovery and Registration Specification (IS-04)

This repository contains details of this AMWA Specification, including Node, Registration and Query APIs, and requirements for Nodes for registry-based and peer-to-peer discovery. with supporting documentation and examples

## Getting started

Readers are advised to be familiar with the JT-NM Reference Architecture (http://jt-nm.org/), before starting with the [Overview](docs/1.0. Overview.md) in this repository. The API specifications are written in RAML -- if a suitable tool is not available for reading this, then [this](APIs/generateHTML) will create HTML versions.

## Contents

* README.md -- This file
* [docs/1.0. Overview.md](docs/1.0. Overview.md) -- Documentation targeting those implementing APIs and clients. Further topics are covered within the [docs/](docs/) directory
* [APIs/NodeAPI.raml](APIs/NodeAPI.raml) -- Normative specification of the NMOS Node API
* [APIs/RegistrationAPI.raml](APIs/RegistrationAPI.raml) -- Normative specification of the NMOS Registration API
* [APIs/QueryAPI.raml](APIs/QueryAPI.raml) -- Normative specification of the NMOS Query API
* [APIs/schemas/](APIs/schemas/) -- JSON schemas used by API specifications
* [APIs/generateHTML](APIs/generateHTML) -- Tool to create HTML browsable version of the API specifications. Requires raml2html (https://github.com/kevinrenskers/raml2html).
* [examples/](examples/) -- Example JSON requests and responses for APIs
* [LICENSE](LICENSE) -- Licenses for software and text documents
* [NOTICE](NOTICE) -- Disclaimer
