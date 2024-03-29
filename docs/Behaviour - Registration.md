# Behaviour: Registration

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

This document covers expected client and server behaviour for interactions between a Node (the client) and the Registration API (the server).

## Standard Registration Sequences

### Initial Registration

#### Generic Node Behaviour

The following behaviour assumes a Node with a single network interface for all traffic, or one which uses a single network interface for control and other interfaces for media traffic. Registrations SHOULD happen via a single interface in each of these cases.

1. A Node is connected to the network.
2. The Node runs an HTTP accessible Node API.
3. The Node produces an mDNS advertisement of type `_nmos-node._tcp` in the `.local` domain as specified in [Node API](../APIs/NodeAPI.raml).
4. The Node performs a DNS-SD browse for services of type `_nmos-register._tcp` as specified in [Discovery: Registered Operation](Discovery%20-%20Registered%20Operation.md).
5. The Node registers itself with the Registration API by taking the object it holds under the Node API's `/self` resource and `POST`ing this to the Registration API.
6. The Node persists itself in the registry by issuing heartbeats as below.
7. The Node registers its other resources (from `/devices`, `/sources`, etc.) with the Registration API. Resources MUST be registered in the correct order, such that a Receiver which references a `device_id` is registered after that corresponding Device (for example).

### Registration Updates

A Node's resources change over time. For example, as specified in [Behaviour: Nodes](Behaviour%20-%20Nodes.md), the `subscription` attributes of Senders and Receivers are updated whenever the configuration is changed. Each resource has a `version` attribute which is updated whenever any change is made to its configuration, as specified in [APIs: Common Keys](APIs%20-%20Common%20Keys.md#version). These changes are exposed in the Node API and registered with the Registration API by `POST`ing each updated resource to the Registration API. The Registration API indicates that it has received an update to a previous record by sending a `200` (OK) response, rather than a `201` (Created) response.

In the case of re-configurable Nodes, resources can also be added to or removed from the Node API to reflect, for example, a change from a configuration as an input Device (with Receivers) to an output device (with Sources, Flows and Senders). A Node assigns an `id` attribute for each added resource, as specified in [Data Model: Identifier Mapping](Data%20Model%20-%20Identifier%20Mapping.md), and sets the `version` attribute to identify the instant at which the change took place. When a previous configuration is restored, assigning the same `id` values enables a control system to re-establish connections, for example. The Node also registers resources that have been added and removed with the Registration API, by making `POST` and `DELETE` requests. 

### Resilient Node Behaviour

In some deployments, multiple copies of essence (video/audio/data) are sent via redundant paths in order to provide guarantees about availability. In these situations, it is likely that a single Node will be used at the point of content creation and transmission via the two paths, and again a single Node used for reception from the two paths.

One way NMOS can model this is as a single Flow sent via two independent Senders which are assigned to separate physical network interfaces on a Node.

Resilient operation via redundancy is also applicable to the NMOS APIs and both peer-to-peer and registered discovery. Registered discovery MAY use either a single registry, or an independent registry for each network.

In order to support this mode and ensure persistence in the registry upon link failure, a Node operating in this mode MAY register with Registration APIs (and host its Node API) via multiple independent network interfaces.

Clients are encouraged to use the `api` attribute rather than the deprecated `href` attribute when accessing a Node API (see [Node API](../APIs/NodeAPI.raml) `/self` resource) as the `href` attribute is likely to target a single network interface only. Nodes which need to support this mode of operation at v1.0 MUST register a different `href` for the same Node `id` with each registry, even though this is a workaround which technically breaches data model constraints.

![Registration example with two independent networks and registries](images/redundant-reg.png)

### Heartbeating

Nodes SHOULD perform a heartbeat every 5 seconds by default, by making HTTP `POST` requests to the `/health/nodes/{nodeId}` endpoint.

Registration APIs SHOULD use a garbage collection interval of 12 seconds by default (triggered just after two failed heartbeats at the default 5 second interval).

It is RECOMMENDED that heartbeat and garbage collection intervals are user-configurable to non-default values in Nodes and Registration APIs respectively. The garbage collection interval MAY be increased without any adverse effects on the registering Nodes. To decrease the garbage collection interval, or increase the heartbeat interval, a system-wide configuration is REQUIRED (see [IS-09](https://specs.amwa.tv/is-09)).

Nodes only need perform a heartbeat to maintain their Node resource in the Registration API. If heartbeats fail over a period greater than the garbage collection interval, both the Node and all registered sub-resources SHOULD be removed from the registry automatically.

### Referential Integrity

In order to permit garbage collection, resources MUST only be accepted by a Registration API where the registry already has a record of the corresponding parent resource.

A Node SHOULD register resources in the following order to avoid rejections due to referential integrity issues:

1. Node: Root entity, which is persisted via heartbeats
2. Devices: Referencing parent Node via `node_id` attribute
3. Sources: Referencing parent Device via `device_id` attribute
4. Flows: Referencing parent Device via `device_id` attribute\*
5. Senders: Referencing parent Device via `device_id` attribute
6. Receivers: Referencing parent Device via `device_id` attribute

\* Version v1.0 Flows do not have a `device_id` and SHOULD be garbage collected based on their parent `source_id`.

Where a `DELETE` is issued against a parent resource, all child resources MUST be removed from the registry immediately.

### Controlled Unregistration

Nodes SHOULD attempt to remove themselves from the registry cleanly on shutdown. This requires HTTP `DELETE` requests to be made for each resource registered via the Registration API. These `DELETE`s SHOULD be carried out on child resources followed by their parents (e.g. Sources which have child Flows are deleted after their children etc.)

If a Node unregisters a resource in the incorrect order, the Registration API MUST clean up related child resources on the Node's behalf in order to prevent stale entries remaining in the registry.

Following deletion of all other resources, the Node resource MAY be deleted and heartbeating stopped.

### Uncontrolled Unregistration

It is expected that some types of Node will be unable to unregister themselves in a clean manner, particularly in cases where a network cable is unplugged. In order to prevent stale resources remaining in the registry, a garbage collection procedure as specified in the 'Heartbeating' section above SHOULD be employed by registry implementers.

### Network Disconnect / Reconnect

If a network cable is temporarily unplugged, dependent on the time for which it remains unplugged and the settings used by the registry, the Node might or might not remain registered. When the Node comes back onto the network it SHOULD proceed as described in the 'Error Conditions' section below covering an inability to connect and timeouts.

## Error Conditions

The following error conditions describe likely scenarios encountered by Nodes when interacting with a Registration API. It is expected that all Node implementations handle these in a sensible fashion as described below.

### Node Encounters HTTP `200` On First Registration

If a Node is restarted, its first action upon discovering a Registration API is to register its Node resource. On first registration with a Registration API this SHOULD result in a `201` (Created) HTTP response code. If a Node receives a `200` (OK) code in this case, a previous record of the Node can be assumed to still exist within the network registry. In order to avoid the registry-held representation of the Node's resources from being out of sync with the Node's view, an HTTP `DELETE` SHOULD be performed in this situation to explicitly clear the registry of the Node and any sub-resources. A new Node registration after this point SHOULD result in the correct `201` (Created) response code.

### Node Encounters HTTP `400` (Or Other Undocumented `4xx`) On Registration

A `400` (Bad Request) error indicates a client error which is likely to be the result of a validation failure identified by the Registration API. The same request MUST NOT be re-attempted without corrective action being taken first.

A registry MAY issue a `400` (Bad Request) code from the `/resource` `POST` endpoint for various reasons, including the following cases. It is not expected that a Node will be able to automatically handle these errors and user intervention could be necessary.

- The request body does not meet the JSON schema for that resource type
- The `id` included in the request has already been used by another resource type held in the registry
- The `version` included in the request is earlier than the matching resource already held in the registry
- A parent resource ID has been modified (for example the `node_id` in a Device registration is modified during an update)
- The parent resource referred to either doesn't exist in the registry or the ID matches the wrong type of resource

Error responses as detailed in the [APIs](APIs.md) documentation can assist with debugging these issues.

### Node Encounters HTTP `409` On Registration Or Heartbeat

A `409` (Conflict) error indicates that the Node has attempted to register or heartbeat with a registry which it is already registered with using a different API version. The Node MUST fully unregister from this registry using its registered API version before proceeding to re-register at the new API version. For more information on supporting multiple versions, see the [Upgrade Path](Upgrade%20Path.md).

### Node Encounters HTTP `404` On Heartbeat

A `404` (Not Found) error on heartbeat indicates that the Node performing the heartbeat is not known to the Registration API. This could be as a result of a number of missed heartbeats which triggered garbage collection in the Registration API. On encountering this code, a Node MUST re-register each of its resources with the Registration API in order.

### Node Encounters HTTP `500` (or other `5xx`), Inability To Connect, Or A Timeout

On registration or heartbeat, any of the following conditions indicates a server side or connectivity issue:

- `500` (Internal Server Error) or other `5xx` error
- Inability to connect
- Timeout

As this issue could affect just one Registration API in a cluster, it is advised that clients identify another Registration API to use from their discovered list. The first interaction with a new Registration API in this case SHOULD be a heartbeat to confirm whether the Node is still present in the registry.

When performing the initial heartbeat with a new Registration API, a `200` (OK) code indicates that the Node and its resources are still present in the registry cluster and no further action is necessary. Future registrations and heartbeats SHOULD be performed against this new Registration API. If a `404` (Not Found) code is encountered when performing this heartbeat, refer to 'Node Encounters HTTP `404` On Heartbeat' above.

Note that in order to achieve efficient failover from one Registration API to another, the Node needs to perform its first heartbeat with the new Registration API within the garbage collection interval following its most recent successful heartbeat. It is therefore advised that Nodes use the heartbeat interval to define their connection timeouts for `/health/nodes/{nodeId}` `POST` requests.

If a `5xx` error is encountered when interacting with all discoverable Registration APIs, clients SHOULD implement an exponential backoff algorithm in their next attempts until a non-`5xx` response code is received.
