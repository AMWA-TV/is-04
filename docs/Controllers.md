# Controllers

_(c) AMWA 2022, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Informative

_JRT NOTE: the references that have strikethrough will be removed before the PR is submitted_

A Controller is Client software that interacts with the NMOS APIs to discover, connect and manage devices within a networked media system.

* This document includes normative references to be followed when implementing a Controller.
* This document covers how the Controller interacts with the NMOS APIs only.
It does not cover other features of the Controller software, such as presentation.
* This document does not cover any requirements relating to where a Controller is additionally acting as a Node (e.g. receiving monitoring information via IS-07).
* Where this document refers to the "user" of a Controller, this includes both human operators who drive the Controller manually and automation systems that drive the Controller programmatically.


## General

### HTTP APIs
#### Trailing Slashes
APIs may advertise URLs with or without a trailing slash. Controllers SHOULD exercise care when appending additional paths to these URLs.
(~~[AMWA Wiki](https://github.com/AMWA-TV/nmos/wiki/Common-Issues)~~)

Controllers performing requests other than GET or HEAD (i.e PUT, POST, DELETE, OPTIONS etc.) MUST use URLs with no trailing slash present.
(~~[IS-08](https://specs.amwa.tv/is-08/releases/v1.0.1/docs/2.0._APIs.html#all-other-requests-put-post-delete-options-etc)~~)

When a server implementation needs to indicate an API URL via an href or similar attribute, it is valid to either include a trailing slash or not provided that the listed path is accessible and follows the above rules. Controllers appending paths to href type attributes MUST support both cases, avoiding doubled or missing slashes.
(~~[IS-05](https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.0._APIs.html#client-behaviour)~~)

#### API Version
Controllers are responsible for identifying the correct API version they require.
(~~[IS-05](https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.0._APIs.html#common-api-base-resource)~~)

Implementers of Controllers are strongly recommended to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.
(~~[IS-08](https://specs.amwa.tv/is-08/releases/v1.0.1/docs/5.0._Upgrade_Path.html#requirements-for-channel-mapping-clients)~~)

Later API versions might use URNs which have not yet been defined and so Controllers MUST be tolerant to these.

#### HTTP Error Codes & Responses
The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.
Where the RAML specification of an API specifies explicit response codes it is expected that a Controller will handle these cases in a particular way.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST instead implement more generic handling for ranges of response codes (1xx, 2xx, 3xx, 4xx and 5xx).
(~~[IS-08](https://specs.amwa.tv/is-08/releases/v1.0.1/docs/2.0._APIs.html#error-codes--responses)~~)

For Controllers performing GET and HEAD requests, using these methods SHOULD correctly handle a 301 (Moved Permanently) response.

When a 301 is supported, the Controller MUST follow the redirect in order to retrieve the required response payload.
(~~[IS-08](https://specs.amwa.tv/is-08/releases/v1.0.1/docs/2.0._APIs.html#get-and-head-requests)~~
~~[IS-05](https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.0._APIs.html#urls-approach-to-trailing-slashes)~~)

If a Controller receives a HTTP 500 response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response’s error field to the user if possible, and indicate that the Resource may be in an unknown state.
The Controller SHOULD also refresh the endpoints of the relevant Resources to ensure the Controller is accurately reflecting the current state of the API.
(~~[IS-08](https://specs.amwa.tv/is-08/releases/v1.0.1/docs/2.1._APIs_-_Controller_Side_Implementation.html#failure-modes)~~)

## Registry Service Discovery	

In order to locate the Registry, the Controller SHOULD support all of the following: 
* Unicast DNS Service Discovery (DNS-SD)
* mDNS
* Direct configuration with the location of a preferred Registry.

The Controller SHOULD offer unicast DNS-SD as the default mechanism. 

Controllers SHOULD observe and interpret all of the TXT records returned with the DNS Service Discovery responses according to the requirements for Query API Clients specified in the [API Paths section of the APIs document](APIs.md#api-paths) in this specification.
(~~[AMWA Wiki](https://github.com/AMWA-TV/nmos/wiki/IS-04-Client)~~
~~[IS-04](https://specs.amwa.tv/is-04/releases/v1.3.1/docs/2.0._APIs.html#api-paths)~~
~~[IS-04](https://specs.amwa.tv/is-04/releases/v1.3.1/docs/6.0._Upgrade_Path.html#requirements-for-registries-registration-and-query-apis)~~)

## Query API
The Controller MUST be capable of using the Registry's IS-04 Query API to discover any registered resource, including Node, Device,  Source, Flow, Sender, and Receiver.

The Controller MUST use the Registry’s IS-04 Query API either via the REST API or by requesting WebSocket subscriptions.

When using the Query API, basic queries SHOULD be used (and advanced query language where available) to cut down on the volume of resources returned to the Controller.	
(~~[AMWA Wiki](https://github.com/AMWA-TV/nmos/wiki/IS-04-Client)~~)

If using the RESTful API rather than WebSockets, Pagination requirements MUST be implemented as specified in the [Pagination section of the APIs: Query Parameters document](APIs%20-%20Query%20Parameters.md#pagination) in this specification.
(~~[IS-04](https://specs.amwa.tv/is-04/releases/v1.3.1/docs/2.5._APIs_-_Query_Parameters.html#pagination)~~)

Controllers SHOULD adhere to the version downgrade requirements for Query API Clients specified in the [Requirements for Query API Clients section of the Upgrade Path document](Upgrade%20Path.md#requirements-for-query-api-clients) in this specification.

## WebSockets & Subscriptions	
Where a WebSocket or other subscription based mechanism is provided for Controller usage, it is strongly recommended that Controllers make use of this and do not use the API resources directly.
In large systems, API resources rely upon pagination in order to return high volumes of data.
This can be both hard to keep track of for a client, and require a large number of requests in order to scan the entire data set.

For this reason it is preferred to use the API resources directly for debug and development purposes only.
(~~[IS-04](https://specs.amwa.tv/is-04/releases/v1.3.1/docs/2.5._APIs_-_Query_Parameters.html#pagination)~~
~~[AMWA Wiki](https://github.com/AMWA-TV/nmos/wiki/Generic-API-Client)~~)

If a WebSocket connection fails, then an attempt to reconnect to the WebSocket MUST NOT be attempted. Instead, a new subscription SHOULD be created with this API or a different one if required. If all available APIs return errors, an exponential backoff algorithm SHOULD be used when retrying until a success code is returned.
(~~[AMWA Wiki](https://github.com/AMWA-TV/nmos/wiki/IS-04-Client)~~)

## Dynamic Update of Resources
The Controller MUST be capable of using the Registry's IS-04 Query API to discover and dynamically update the state of any registered resource, including Node, Device,  Source, Flow, Sender, and Receiver.

* The Controller MUST indicate available Senders to the user.
* The Controller MUST dynamically indicate to the user when a Sender is put ‘offline’ or put back 'online'
* The Controller MUST indicate to the user which of the discovered Receivers are controllable via the IS-05 Connection API, for instance, allowing Senders to be connected.
* The Controller MUST indicate to the user which Receivers have a Connection API, but can choose not to display Receivers without a Connection API
