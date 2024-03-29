# Discovery: Registered Operation

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

This document describes usage of NMOS APIs for discovery in cases where where a distributed registry is available.

## Registration API

### DNS-SD Advertisement

The preferred method of Registration API advertisement is via unicast DNS-SD advertisement of the type `_nmos-register._tcp`. Registration APIs MUST additionally be capable of producing an mDNS advertisement. The Registry MAY provide a user-configurable method to disable this advertisement.

Registration APIs supporting versions `v1.2` and below MUST additionally be capable of producing an mDNS advertisement of type `_nmos-registration._tcp`. The Registry MAY provide a user-configurable method to disable this advertisement.

*Note: [RFC 6763 Section 7.2](https://tools.ietf.org/html/rfc6763#section-7.2) specifies that the maximum service name length for an mDNS advertisement is 16 characters when including the leading underscore, but "`_nmos-registration`" is 18 characters.*

The IP address and port of the Registration API MUST be identified via the DNS-SD advertisement, with the full HTTP path then being resolved via the standard NMOS API path documentation.

Multiple DNS-SD advertisements for the same API are permitted where the API is exposed via multiple ports and/or protocols.

### DNS-SD TXT Records

#### `api_proto`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_proto` with a value of either `http` or `https` dependent on the protocol in use by the Registration API web server.

#### `api_ver`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_ver`. The value of this TXT record is a comma separated list of API versions supported by the server. For example: `v1.0,v1.1,v2.0`. There SHOULD be no whitespace between commas, and versions SHOULD be listed in ascending order.

#### `api_auth`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_auth` with a value of either `true` or `false` dependent on whether authorization is needed for Registration API requests.

#### `pri`

The DNS-SD advertisement MUST include a TXT record with key `pri` and an integer value. Servers MAY additionally represent a matching priority via the DNS-SD SRV record `priority` and `weight` (see RFC 2782). The TXT record SHOULD be used in favour to the SRV priority and weight where these values differ in order to overcome issues in the Bonjour and Avahi implementations.
Values 0 to 99 correspond to an active NMOS Registration API (zero being the highest priority). Values 100+ are reserved for development work to avoid colliding with a live system.

### Client Interaction Procedure

1. Node comes online

2. Node scans for an active Registration API on the network using unicast and/or multicast DNS service discovery (type `_nmos-register._tcp`) as described in the [Discovery](Discovery.md#unicast-vs-multicast-dns-sd) document.

   - Nodes which support v1.2 and earlier versions MUST additionally browse for the deprecated service type `_nmos-registration._tcp`.

3. Given multiple returned Registration APIs, the Node orders these based on their advertised priority (TXT `pri`), filtering out any APIs which do not support the desired API version, protocol and authorization mode (TXT `api_ver`, `api_proto` and `api_auth`).

   - Where a Node supports multiple API versions simultaneously, see the [Upgrade Path](Upgrade%20Path.md) for additional requirements in filtering the discovered API list.

4. The Node selects a Registration API to use based on the priority, and a random selection if multiple Registration APIs of the same API version with the same priority are identified.

5. Node proceeds to register its resources with the selected Registration API.

If the chosen Registration API does not respond correctly at any time, another Registration API SHOULD be selected from the discovered list. If no further Registration APIs are available or TTLs on advertised services have expired, a re-query MAY be performed.

If no Registration APIs are advertised on a network, the Node SHOULD assume peer-to-peer operation unless configured otherwise. The REQUIRED TXT record advertisements for this mode are described in the [Peer-to-Peer Operation](Discovery%20-%20Peer%20to%20Peer%20Operation.md) documentation.

## Query API

### DNS-SD Advertisement

The preferred method of Query API advertisement is via unicast DNS-SD advertisement of the type `_nmos-query._tcp`. Query APIs MUST additionally be capable of producing an mDNS advertisement. The Registry MAY provide a user-configurable method to disable this advertisement.

The IP address and port of the Query API MUST be identified via the DNS-SD advertisement, with the full HTTP path then being resolved via the standard NMOS API path documentation.

Multiple DNS-SD advertisements for the same API are permitted where the API is exposed via multiple ports and/or protocols.

### DNS-SD TXT Records

#### `api_proto`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_proto` with a value of either `http` or `https` dependent on the protocol in use by the Query API web server.

#### `api_ver`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_ver`. The value of this TXT record is a comma separated list of API versions supported by the server. For example: `v1.0,v1.1,v2.0`. There SHOULD be no whitespace between commas, and versions SHOULD be listed in ascending order.

#### `api_auth`

The DNS-SD advertisement MUST be accompanied by a TXT record of name `api_auth` with a value of either `true` or `false` dependent on whether authorization is needed in order to interact with the Query API or not.

#### `pri`

The DNS-SD advertisement MUST include a TXT record with key `pri` and an integer value. Servers MAY additionally represent a matching priority via the DNS-SD SRV record `priority` and `weight` (see RFC 2782). The TXT record SHOULD be used in favour to the SRV priority and weight where these values differ in order to overcome issues in the Bonjour and Avahi implementations.
Values 0 to 99 correspond to an active NMOS Query API (zero being the highest priority). Values 100+ are reserved for development work to avoid colliding with a live system.

### Client Interaction Procedure

1. Client (such as a Node or control interface) comes online

2. Client scans for an active Query API on the network using unicast and/or multicast DNS service discovery (type `_nmos-query._tcp`) as described in the [Discovery](Discovery.md#unicast-vs-multicast-dns-sd) document.

3. Given multiple returned Query APIs, the client orders these based on their advertised priority (TXT `pri`), filtering out any APIs which do not support the desired API version, protocol and authorization mode (TXT `api_ver`, `api_proto` and `api_auth`).

   - Where a client supports multiple API versions simultaneously, see the [Upgrade Path](Upgrade%20Path.md) for additional requirements in filtering the discovered API list.

4. The client selects a Query API to use based on the priority, and a random selection if multiple Query APIs of the same version with the same priority are identified.

5. Client requests data from the selected Query API.

If the chosen Query API does not respond correctly at any time, another Query API SHOULD be selected from the discovered list. If no further Query APIs are available or TTLs on advertised services have expired, a re-query MAY be performed.

If no Query APIs are advertised on a network, the client SHOULD assume peer-to-peer operation (if supported) unless configured otherwise.
