# **[Proposed Specification]** AMWA NMOS Discovery and Registration Specification

This repository contains details of this AMWA Specification, including Node, Registration and Query APIs, and requirements for Nodes for registry-based and peer-to-peer discovery. with supporting documentation and examples

## Getting started

Readers are advised to be familiar with the NMOS Technical Overview at (https://github.com/AMWA-TV/nmos) and then read the [API Overview](APIOverview.md) in this repository. The API specifications are written in RAML -- if a suitable tool is not available for reading this, then [this](APIs/generateHTML) will create HTML versions. 

## Contents

* README.md -- This file
* [APIOverview.md](APIOverview.md) -- Overview of APIs, including parts of the specification common to all APIs
* [P2POperation.md](P2POperation.md) -- Overview of peer-to-peer discovery (without a distributed registry)
* [APIs/NodeAPI.raml](APIs/NodeAPI.raml) -- Normative specification of the NMOS Node API
* [APIs/RegistrationAPI.raml](APIs/RegistrationAPI.raml) -- Normative specification of the NMOS Registration API
* [APIs/QueryAPI.raml](APIs/QueryAPI.raml) -- Normative specification of the NMOS Query API
* [APIs/schemas/](APIs/schemas/) -- JSON schemas used by API specifications
* [APIs/generateHTML](APIs/generateHTML) -- Tool to create HTML browsable version of the API specifications. Requires raml2html (https://github.com/kevinrenskers/raml2html).
* [examples/](examples/) -- Example JSON requests and responses for APIs
* [LICENSE](LICENSE) -- Licenses for software and text documents
* [NOTICE](NOTICE) -- Disclaimer
