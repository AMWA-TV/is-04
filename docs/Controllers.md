# Controllers

_(c) AMWA 2022, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Informative

A Controller is Client software that interacts with the NMOS APIs to discover, connect and manage devices within a networked media system.

* This document includes normative references to be followed when implementing a Controller.
* This document covers how the Controller interacts with the NMOS APIs only.
It does not cover other features of the Controller software, such as presentation.
* This document does not cover any requirements relating to where a Controller is additionally acting as a Node (e.g. receiving monitoring information via IS-07).

## General

### User
Where this document refers to the "user" of a Controller, this includes both human operators who drive the Controller manually and automation systems that drive the Controller programmatically.

### HTTP APIs
#### Trailing Slashes
APIs may advertise URLs with or without a trailing slash.
Controllers appending paths to `href` type attributes MUST support both cases, avoiding doubled or missing slashes.

Controllers performing requests other than GET or HEAD (i.e PUT, POST, DELETE, OPTIONS etc.) MUST use URLs with no trailing slash present.

#### API Version
Controllers are responsible for identifying the correct API version they require.

Implementers of Controllers are strongly recommended to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.

Later API versions might use URNs which have not yet been defined and so Controllers MUST be tolerant to these.

#### Error Codes & Responses
The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (1xx, 2xx, 3xx, 4xx and 5xx).
However, where the RAML specification of an API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

For Controllers performing `GET` and `HEAD` requests, using these methods SHOULD correctly handle a `301` (Moved Permanently) response.

When a 301 is supported, the Controller MUST follow the redirect in order to retrieve the required response payload.

If a Controller receives a HTTP 500 response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response’s error field to the user if possible, and indicate that the Resource may be in an unknown state.
The Controller SHOULD also refresh the endpoints of the relevant Resources to ensure the Controller is accurately reflecting the current state of the API.

## Registry Service Discovery	

In order to locate the Registry, the Controller SHOULD support all of the following: 
* Unicast DNS Service Discovery (DNS-SD).
* Multicast DNS Service Discovery (mDNS).
* Direct configuration with the location of a preferred Registry.

The Controller SHOULD offer unicast DNS-SD as the default mechanism. 

Controllers SHOULD observe and interpret all of the TXT records returned with the DNS Service Discovery responses according to the requirements for Query API Clients specified in the [API Paths section of the APIs document](APIs.md#api-paths) in this specification.

## Query API
The Controller MUST be capable of using the Registry's IS-04 Query API to discover any registered resource, including Node, Device,  Source, Flow, Sender, and Receiver,
as described in the [APIs section](README.md#apis) of this specification.

The Controller MUST use the Registry’s IS-04 Query API either via the REST API or by requesting WebSocket subscriptions.

When using the Query API, basic queries SHOULD be used (and advanced query language where available) to cut down on the volume of resources returned to the Controller.	

Controllers SHOULD adhere to the version downgrade requirements for Query API Clients specified in the [Requirements for Query API Clients section of the Upgrade Path document](Upgrade%20Path.md#requirements-for-query-api-clients) in this specification.

## Pagination
In large systems, API resources rely upon pagination in order to return high volumes of data.
This can be both hard to keep track of for a client, and require a large number of requests in order to scan the entire data set.

For this reason it is recommended to use the RESTful QUERY API for debug and development purposes only.

If using the RESTful Query API rather than WebSockets, Pagination requirements MUST be implemented as specified in the [Pagination section of the APIs: Query Parameters document](APIs%20-%20Query%20Parameters.md#pagination) in this specification.
	
## WebSockets & Subscriptions	
Where a WebSocket or other subscription based mechanism is provided for Controller usage, it is strongly recommended that Controllers make use of this and do not use the API resources directly.

If a WebSocket connection fails, then an attempt to reconnect to the WebSocket SHOULD NOT be attempted. Instead, a new subscription SHOULD be created with this API or a different one if required. If all available APIs return errors, an exponential backoff algorithm SHOULD be used when retrying until a success code is returned.

## Dynamic Update of Resources
The Controller MUST be capable of using the Registry's IS-04 Query API to discover and dynamically update the state of any registered resource, including Node, Device,  Source, Flow, Sender, and Receiver.

* The Controller MUST indicate available Senders to the user.
* The Controller MUST dynamically indicate to the user when a Sender is put ‘offline’ or put back 'online'.
* The Controller MUST indicate available Receivers to the user which have an IS-05 Connection API.
However, the Controller can choose not to display discovered Receivers without an IS-05 Connection API.
