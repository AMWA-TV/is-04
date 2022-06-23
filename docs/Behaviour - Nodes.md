# Behaviour: Nodes

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## API Resources

Where the behaviour associated with an API attribute is not sufficiently clear from its name and schema constraints, this is documented below.

### All Resources

`caps`: Capabilities are intended to signal a collection of inputs or outputs which a given resource is able to consume or produce, but which it might not be doing at this instant. For example, Receiver capabilities indicate the types of data a Receiver can consume from a network. The specification defines capabilities of `media_types` and `event_types` for Receivers which take an array form.

Additions to capabilities and the structure which they use can be made using the AMWA process and criteria defined in the [NMOS Parameter Registers](https://specs.amwa.tv/nmos-parameter-registers/). Extensions to capabilities are documented in the [Capabilities register](https://specs.amwa.tv/nmos-parameter-registers/branches/main/capabilities/).

New top-level attributes can also be added for each resource type via the AMWA process and criteria defined in the the NMOS Parameter Registers, which ensures such additions are compatible with the schemas in this specification. For example, additional Flow attributes are documented in the [Flow Attributes register](https://specs.amwa.tv/nmos-parameter-registers/branches/main/flow-attributes/).

### Senders

`subscription`: The `subscription` key is used to indicate how a Sender currently connects to Receivers in a networked media system. The subscription MUST be updated to reflect the current configuration of the Sender whether it was modified via an NMOS mechanism or an externally-defined control mechanism.

`subscription` `active`: The `active` key MUST be set to `true` when the Sender is configured to enable transmission of packets to the network, whether via a push- or pull-based mechanism. The key MUST be set to `false` when the Sender is configured to disable transmission of packets to the network.

`subscription` `receiver_id`: The `receiver_id` key MUST be set to `null` in all cases except where a unicast push-based Sender is configured to transmit to an NMOS Receiver, and the `active` key is set to `true`. When not set to `null`, the `receiver_id` MUST be set to the UUID of an NMOS Receiver.

`interface_bindings`: For push-based transports the Sender `interface_bindings` SHOULD contain a single network interface unless a redundancy mechanism such as ST 2022-7 is in use, in which case each 'leg' SHOULD have its matching interface listed. Where the redundancy mechanism sends more than one copy of the stream via the same interface, that interface SHOULD be listed a corresponding number of times. For pull-based transports the Sender `interface_bindings` SHOULD list each interface on which the Sender is listening for connections.

`manifest_href`: The Sender `manifest_href` SHOULD provide an HTTP(S) accessible URL to a file describing how to connect to the Sender (SDP in the case of RTP). The Sender's `version` attribute SHOULD be updated if the contents of this file are modified. This URL MAY return an HTTP `404` (Not Found) where the `active` parameter in the `subscription` object is present and set to `false` (v1.2+ only). The value SHOULD be `null` when the transport type used by the Sender does not require a transport file.

### Receivers

`subscription`: The `subscription` key is used to indicate how a Receiver currently connects to Senders in a networked media system. The subscription MUST be updated to reflect the current configuration of the Receiver whether it was modified via an NMOS mechanism or an externally-defined control mechanism.

`subscription` `active`: The `active` key MUST be set to `true` when the Receiver is configured to enable reception of packets from the network. The key MUST be set to `false` when the Receiver is configured to disable reception of packets from the network.

`subscription` `sender_id`: The `sender_id` key MUST be set to `null` in all cases except where the Receiver is currently configured to receive from an NMOS Sender, and the `active` key is set to `true`. When not set to `null`, the `sender_id` MUST be set to the UUID of an NMOS Sender.

`interface_bindings`: For push-based transports the Receiver `interface_bindings` SHOULD contain a single network interface unless a redundancy mechanism such as ST 2022-7 is in use, in which case each 'leg' SHOULD have its matching interface listed. Where the redundancy mechanism receives more than one copy of the stream via the same interface, that interface SHOULD be listed a corresponding number of times. For pull-based transports the Receiver `interface_bindings` SHOULD list a single interface through which content is being consumed.

## Modifying Receiver Subscriptions

This method is deprecated, but SHOULD be supported alongside any other connection mechanisms up to and including v1.2. From v1.3 Nodes MAY choose to return a `501` (Not Implemented) response from this endpoint as opposed to implementing it.

Please see the NMOS Connection API specification for the current methods for creating connections between Senders and Receivers.

A `PUT` request to `/receivers/{receiverId}/target` of the Node API will modify which Sender a Receiver is subscribed to.

In order to subscribe a Receiver to a Sender, a `PUT` request SHOULD be made to this resource containing a full Sender object.
In order to unsubscribe a Receiver from a Sender, an empty object `{}` SHOULD be used in this `PUT` request.
In both cases the target resource SHOULD respond with a `202` (Accepted) code on success, and a response body matching the request body.

The Receiver's subscription object contains a `sender_id` attribute which MUST be updated once a Receiver has successfully requested, parsed and actioned a change based on the Sender's transport file (SDP in the case of RTP).
