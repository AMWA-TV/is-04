# Discovery: Peer-to-Peer Operation

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

This document describes usage of NMOS APIs for discovery in cases where where a distributed registry is not available, such as small ad-hoc installations. This feature is OPTIONAL from v1.3 of the specification.

Note that the peer-to-peer discovery mechanism depends upon mDNS which is not intended to operate over IP routed boundaries (i.e. between network subnets). As such it is RECOMMENDED that for most use cases, in particular fixed installations and those requiring high levels of resilience, the registered discovery mechanism is used.

## Pre-Requisites

When configured for peer-to-peer discovery, a Node MUST advertise its presence with mDNS.

In the absence of a network registry, a Node MUST also indicate the validity of its API resources with mDNS TXT records.

Both of the above are properties of the [Node API](../APIs/NodeAPI.raml) and require no additional implementation steps.

## DNS-SD Advertisement

Node APIs MAY produce an mDNS advertisement of the type `_nmos-node._tcp` in order to support peer-to-peer operation. This SHOULD NOT be advertised when a Registration API is present on the network, or when peer-to-peer operation is disabled.

The IP address and port of the Node API MUST be identified via the DNS-SD advertisement, with the full HTTP path then being resolved via the standard NMOS API path documentation.

Multiple DNS-SD advertisements for the same API are permitted where the API is exposed via multiple ports and/or protocols.

From v1.3, Node mDNS announcements SHOULD only be used for peer-to-peer mode as they generate unnecessary network traffic. However a Node supporting multiple versions including v1.2 or below MUST still provide mDNS announcements as they were compulsory prior to v1.3.

## DNS-SD TXT records

### `api_proto`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_proto` with a value of either `http` or `https` (lower-case) dependent on the protocol in use by the Node API web server.

### `api_ver`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_ver`. The value of this TXT record is a comma separated list of API versions supported by the server. For example: `v1.0,v1.1,v2.0`. There SHOULD be no whitespace between commas, and versions SHOULD be listed in ascending order.

### `api_auth`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_auth` with a value of either `true` or `false` dependent on whether authorization is needed for Node API requests.

### `ver_`

When a Node is operating in peer-to-peer mode it MUST additionally advertise the following mDNS TXT records as part of its Node advertisement. If a Node is successfully registered with a Registration API it MUST withdraw advertisements of these TXT records. There is no requirement to register these TXT records with a unicast DNS service.

| **TXT Record Name** | **Corresponding Node API Resource** |
|---------------------|-------------------------------------|
| `ver_slf`           | `/self`                             |
| `ver_src`           | `/sources`                          |
| `ver_flw`           | `/flows`                            |
| `ver_dvc`           | `/devices`                          |
| `ver_snd`           | `/senders`                          |
| `ver_rcv`           | `/receivers`                        |

The value of each of the above SHOULD be the text representation of an unsigned 8-bit integer initialised to 0. This integer MUST be incremented and mDNS TXT record updated whenever a change is made to the corresponding HTTP API resource on the Node. The integer MUST wrap back to a value of 0 after reaching a maximum value of 255.

For example, the `ver_src` TXT record MUST be created when the Node first advertises itself via mDNS. If the data held within the HTTP resources under `/sources` is added to, removed from or edited, then the `ver_src` text record MUST be modified (value incremented). The `version` attribute of each resource indicates which specific resources have changed, as specified in [APIs: Common Keys](APIs%20-%20Common%20Keys.md#version).

### Client Interaction Procedure

The following scenario describes a peer-to-peer discovery in which a Node features an onboard control interface (for example a display with an input source menu).

1. Node comes online
2. Node scans for an active Query API on the network (type `_nmos-query._tcp`)
3. Given no active Query API, Node scans mDNS for other Nodes (type `_nmos-node._tcp`)
4. Using the returned list of Nodes, the requesting Node can request data from remote Node API resources as needed to populate a control interface. This could be as simple as requesting the `/senders` resource.
5. The Node continues to monitor for changes to Node advertisements via mDNS. When Node API resources are changed, the TXT records associated with each Node will be updated to indicate which API resource(s) have been updated (see [Node API specification](../APIs/NodeAPI.raml))
6. The Node SHOULD not re-poll remote Nodes on a timer in order to gather data about updated API resources
7. The Node can perform connection management tasks automatically without user intervention provided they only affect that Node's operation. This includes but is not limited to automatically routing video from a discovered Sender to a display's Receiver

If a Query API becomes available on the network during peer-to-peer operation, the Node modifies its behaviour in one of the following two ways:

- The Node's control interface switches to communicating with the network Query API rather than polling Nodes directly
- The Node's control interface exposed to the user is disabled (if Query API interactions are not supported)

## Recommendations for Dual-Mode Operation

To allow both peer-to-peer operation and operation using a distributed Query API:

- When collecting data from other Nodes in peer-to-peer mode, Nodes SHOULD populate an interface which replicates the structure of a Query API, but restricted to access from localhost only, with no Query API mDNS advertisement.
- When a network Query API becomes available, the localhost-based Query API MAY proxy requests through to the network Query API in order to provide a transparent transition to the client interface.
