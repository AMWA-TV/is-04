# APIs: Load Balancing & Redundancy

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Registration API

- An HTTP load balancing proxy (such as HAProxy) MAY be inserted in front of multiple Registration API instances which share a common registry. In this instance the proxy is the entity advertised via DNS-SD (rather than individual Registration APIs).
- Multiple Registration APIs MAY exist as separate entities in a network, but with a common registry. Each API SHOULD be advertised via a separate DNS-SD record. Priorities MAY be defined for each of these APIs to determine an order of precedence for their usage by clients.

## Query API

- An HTTP load balancing proxy (such as HAProxy) MAY be inserted in front of multiple Query API instances which share a common registry. In this instance the proxy is the entity advertised via DNS-SD (rather than individual Query APIs).
- Multiple Query APIs MAY exist as separate entities in a network, but with a common registry. Each API SHOULD be advertised via a separate DNS-SD record. Priorities MAY be defined for each of these APIs to determine an order of precedence for their usage by clients.
- An HTTP cache layer MAY be used in front of a Query API instance to reduce the load on the system provided this cache is invalidated when resources held in the registry are changed.

## Node API

- An HTTP cache layer MAY be used in front of a Node API instance to reduce the load on the system (see note below on low powered devices).

### Low Powered Devices

Low powered Nodes MAY be deployed with an HTTP caching layer in front of them to support demanding use cases. It is suggested as a result that manufacturers of such devices provide the option for the user to manually replace the hostname used by the device in any `href` attributes exposed in APIs and registrations. By replacing this hostname with the location of the cache layer, this load can be managed externally to the device.
