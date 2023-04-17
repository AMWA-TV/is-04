# Controllers

_(c) AMWA 2022, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Introduction

A Controller is Client software that interacts with the NMOS APIs to discover, connect and manage resources (Nodes, Devices, Senders and Receivers) within a networked media system.

* This document includes normative references to be followed when implementing a Controller.
* This document covers how the Controller interacts with the NMOS APIs only.
  It does not cover other features of the Controller software, such as presentation.
* This document does not cover any requirements relating to where a Controller is additionally acting as a Node (e.g. receiving monitoring information via IS-07).

Where this document refers to a User, this can include both human operators who drive a Controller manually and automation systems that drive a Controller programmatically.

## General

### HTTP APIs

#### Trailing Slashes

Controllers appending paths to `href` type attributes MUST support URLs both with and without a trailing slash, to avoid doubled or missing slashes.

Controllers performing requests other than `GET` or `HEAD` (i.e `PUT`, `POST`, `DELETE`, `OPTIONS` etc.) MUST use URLs with no trailing slash present.

#### API Versions

The versioning format is `v<MAJOR>.<MINOR>`
* `MINOR` increments will be performed for non-breaking changes (such as the addition of attributes in a response)
* `MAJOR` increments will be performed for breaking changes (such as the renaming of a resource or attribute)

Versions MUST be represented as complete strings. Parsing MUST proceed as follows: separate into two strings, using the point (`.`) as a delimiter. Compare integer representations of `MAJOR`, `MINOR` version (such that v1.12 is greater than v1.5).

Implementers of Controllers are RECOMMENDED to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.

#### API Common Keys

Controllers MUST follow the requirements for common API keys specified in the [IS-04 APIs: Common Keys](APIs%20-%20Common%20Keys.md) document including the requirements regarding [use of URNs](APIs%20-%20Common%20Keys.md#use-of-urns).

#### Error Codes & Responses

The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (`1xx`, `2xx`, `3xx`, `4xx` and `5xx`).
However, where the API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

When a Controller performs `GET` and `HEAD` requests, it MUST correctly handle a `301` (Moved Permanently) redirect to accommodate the API implementations permitted in the [APIs: URLs: Approach to Trailing Slashes](APIs.md#urls-approach-to-trailing-slashes) section of this specification.

If a Controller receives an HTTP `5xx` or `4xx` response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response's `error` field to the User if possible.

## Query API Discovery	

NMOS [Discovery](Discovery.md) makes use of the DNS Service Discovery (DNS-SD) protocol in both Registered Operation and Peer-to-Peer Operation.
The Controller MUST support registered operation as specified in the [Query API: Client Interaction Procedure](Discovery%20-%20Registered%20Operation.md#client-interaction-procedure-1) section of this specification.

In order to locate the Query API, the Controller SHOULD support all of the following:

* Unicast DNS
* Multicast DNS (mDNS)
* Direct configuration with the location of a preferred Query API

The Controller SHOULD offer unicast DNS-SD as the default mechanism. 

Controllers MUST observe and interpret all of the TXT records returned with the DNS Service Discovery responses according to the requirements for Query API Clients specified in the [APIs: API Paths](APIs.md#api-paths) section of this specification.

## Query API

In registered operation, the Controller MUST use the Query API to discover any registered resource, including Node, Device, Source, Flow, Sender, and Receiver,
as described in the [APIs](APIs.md) section of this specification.

When using the Query API, query filters SHOULD be used (and advanced query language where available) to cut down on the volume of resources returned to the Controller, as specified in the [APIs: Query Parameters](APIs%20-%20Query%20Parameters.md) document.

Controllers MUST adhere to the [Requirements for Query API Clients](Upgrade%20Path.md#requirements-for-query-api-clients) found in this specification.

## Pagination

If using the HTTP API rather than WebSocket subscriptions, pagination requirements MUST be implemented as specified in the [APIs: Query Parameters: Pagination](APIs%20-%20Query%20Parameters.md#pagination) section of this specification.
	
## WebSocket Subscriptions	

In order to avoid polling of the HTTP API, it is RECOMMENDED that Controllers use the WebSocket subscription mechanism.

## Dynamic Update of Resources

In registered operation, the Controller uses the Query API to discover and track the state of any registered resource, including Node, Device, Source, Flow, Sender, and Receiver.

* The Controller MUST indicate available Senders to the user.
* The Controller MUST reflect changes in presence/absence of Senders to the user after a maximum of 30 seconds.
* The Controller MUST indicate available Receivers to the user which have an IS-05 Connection API.
  However, the Controller MAY choose to omit discovered Receivers without an IS-05 Connection API.

If the controller supports peer-to-peer operation when a Query API is not available, the Controller discovers and tracks the state of resources as specified in the [Peer-to-Peer Operation: Client Interaction Procedure](Discovery%20-%20Peer%20to%20Peer%20Operation.md#client-interaction-procedure) section of this specification.
