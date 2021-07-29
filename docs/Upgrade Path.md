# Upgrade Path

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

As is common with web APIs, over time changes will be made to support new use cases and deprecate old ways of working. The NMOS APIs are no different, and have been designed to permit in-service upgrades across a facility which might be running large amounts of equipment with support for different versions of these specifications.

API versioning is specified in the [APIs](APIs.md) documentation, with procedures for handling upgrades described below.

## Requirements for Nodes (Node APIs)

Node API implementations MUST support at least one API version, and MAY support more than one at a time. Note however that a Node MUST only perform interactions with a Registration API at a single version. Nodes implementing multiple API versions MAY provide a user-configurable choice for which API version to register and/or query using. Otherwise it is expected that the Node will select a Registration API which supports the highest API version which the Node also supports. The API version SHOULD be selected before considering the Registration API's configured `priority`.

Registrations MUST NOT proceed if the Node API version implemented does not exactly match the API version used by the Registration API.

Where a Node implements version v1.2 or below, it MUST browse for both the `_nmos-register._tcp` DNS-SD service type, and the legacy `_nmos-registration._tcp` DNS-SD service type in order to retrieve the full list of available Registration APIs. De-duplication SHOULD be performed against this returned list.

## Requirements for Registries (Registration and Query APIs)

Implementers of the Registration and Query API MUST support at least one API version. It is however strongly RECOMMENDED that Registration and Query APIs fully support at least two and preferably more consecutive API versions (if released). In doing so, facilities which include a large number of Nodes can stagger their equipment upgrades whilst maintaining compatibility with a single registry.

When supporting multiple API versions, Query APIs MUST provide translations of resources for backwards compatibility (see [Version Translations](#version-translations)). For example, if the registry contains a mixture of v1.0 and v1.1 resources, a v1.0 Query API needs to to provide a response containing all of these resources by removing keys from v1.1 resources which are not present in v1.0. Translations MUST NOT be provided for `/subscriptions` endpoints, which only expose subscriptions matching the endpoint's API version.

Query APIs do not need to provide for forwards compatibility as it might be impossible to generate data for new attributes in schemas. Query APIs SHOULD however allow clients to request older data than the requested minor API version by using the `query.downgrade=<version>` query parameter (see Query API documentation for examples).

### Version Translations

When conforming a resource to an earlier API version, Query API implementations SHOULD make best efforts to remove attributes which were not references in earlier versions' schemas. The core attributes which fall into this category are documented here for clarity, but the same data could be derived from analysis of the schema changes between API versions. Implementers need to be aware that in the future new attributes can be defined externally to this specification.

Note that removal of these keys does not guarantee conformance to the schema of the earlier API version due to the addition of new `enum` values and similar features in more recent API versions. As such, Query APIs SHOULD NOT validate translated resources against schemas.

Nodes which support multiple versions simultaneously MUST ensure that all of their resources meet the schemas for each corresponding version of the specification which is supported. Where necessary features are only available in the most recent version(s) of the specification it could be necessary to expose only a limited subset of a Node's resources from lower versioned endpoints.

### v1.3 to v1.2

- Nodes: `attached_network_device` (in `interfaces`), `authorization` (in `api` `endpoints`), `authorization` (in `services`)
- Devices: `authorization` (in `controls`)
- Sources: `event_type`
- Flows: `event_type`

### v1.2 to v1.1

- Nodes: `interfaces`
- Senders: `caps`, `interface_bindings`, `subscription`
- Receivers: `interface_bindings`, `active` (in `subscription`)

### v1.1 to v1.0

- Nodes: `api`, `clocks`, `description`, `tags`
- Devices: `controls`, `description`, `tags`
- Sources: `channels`, `clock_name`, `grain_rate`
- Flows: `bit_depth`, `colorspace`, `components`, `device_id`, `DID_SDID`, `frame_height`, `frame_width`, `grain_rate`, `interlace_mode`, `media_type`, `sample_rate`, `transfer_characteristic`

## Requirements for Query API Clients

Query API clients MUST support at least one API version. It is strongly RECOMMENDED that clients use the query downgrade mechanism in order to provide access to the widest possible range of Nodes' resources.

Clients SHOULD NOT attempt to access attributes introduced by a later Query API version. Whilst the [Version Translation](#version-translations) mechanism removes access to invalid additional keys, new values for existing keys are not excluded by this mechanism and need to be handled gracefully.

It is strongly RECOMMENDED to match Query API client compatibility to the maximum API version supported by a given Query API instance prior to introducing any Nodes supporting that API version to an existing system. Parameters which are known to introduce this issue are noted below:

### Affected Keys From v1.3

- Devices: `type` could be listed as any new variant of `urn:x-nmos:device`
- Flows: `transfer_characteristic` could be listed as any string to permit future extensibility
- Flows: `colorspace` could be listed as any string to permit future extensibility
- Senders: `transport` could be listed as any new variant of `urn:x-nmos:transport`
- Senders: `manifest_href` could be listed as `null` for transport types that do not require a transport file
- Receivers: `transport` could be listed as any new variant of `urn:x-nmos:transport`

### Affected Keys From v1.2

No keys are affected

### Affected Keys From v1.1

- Sources: `format` could be listed as `urn:x-nmos:format:mux`
- Flows: `format` could be listed as `urn:x-nmos:format:mux`
- Senders: `flow_id` could be listed as `null`

## Performing Upgrades

The following procedure is suggested for a live system which needs to migrate between API versions. This guide assumes that the registry and key clients support the Query API downgrade feature.

- Upgrade the Query API(s) to support serving the new version of responses, whilst providing backwards compatibility to old versions active in the running system.
- Upgrade Query API clients which support the `query.downgrade` parameter and as such can still access all data in the system. Check ahead of doing this that the Query API server implementation supports the downgrade feature.
- Upgrade the registry and Registration API(s) to support registrations using the new version, whilst continuing to support registrations at the old version.
- Upgrade Nodes in the system to register against the new API version. Any Nodes which also interact with the Query API will continue to query using the old version initially unless they support downgrade queries.
- Once all relevant Nodes have been upgraded, all Query API clients can be upgraded or instructed to perform queries against the new version.
