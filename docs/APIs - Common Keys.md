# APIs: Common Keys

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

A number of common keys are used within NMOS APIs. Their definitions, semantics and permitted values are described below.

## ID

Core resources such as Sources, Flows, Nodes etc. include an `id` attribute. Resource identity is explained in the [Data Model](Data%20Model.md) and [Identifier Persistence & Generation](Data%20Model%20-%20Identifier%20Mapping.md#identifier-persistence--generation) sections of this specification.

The `id` attribute is a UUID, formatted as a string of 32 lowercase hex digits in groups of 8, 4, 4, 4, 12 separated by `-`, for example: `f81d4fae-7dec-11d0-a765-00a0c91e6bf6`.

## Version

Core resources such as Sources, Flows, Nodes etc. include a `version` attribute. As properties of a given Flow or similar will change over its lifetime, the version identifies the instant at which this change took place. For example, if a vision mix transition occurred which resulted in a change to the `parents` which make up a particular Flow, the `version` is modified to reflect the wall clock instant at which this change occurred.

`version` is a TAI timestamp. In NMOS APIS, a TAI timestamp is represented as a string of the format: `<seconds>:<nanoseconds>`. Note the  `:` as opposed to a `.`, indicating that the value `1439299836:10` is interpreted as 1439299836 seconds and 10 nanoseconds.

Combining the version with the resource's ID attribute creates a hash which can be used to uniquely identify a particular variant of a Source, Flow or similar.

In registered operation, whenever a Node's resources are updated, the change is registered with the Registration API, as specified in [Behaviour: Registration](Behaviour%20-%20Registration.md#registration-updates). In peer-to-peer operation, the change is advertised using the `ver_` TXT records, as specified in [Discovery: Peer-to-Peer Operation](Discovery%20-%20Peer%20to%20Peer%20Operation.md#ver_).

## Label

Freeform human readable string to be used within user interfaces.

## Description

Freeform human readable string to be used within user interfaces.

## Format

A URN describing the data format of a video, audio or data flow.

| **Permitted Value**       | **Valid From API Version** |
|---------------------------|----------------------------|
| `urn:x-nmos:format:video` | v1.0                       |
| `urn:x-nmos:format:audio` | v1.0                       |
| `urn:x-nmos:format:data`  | v1.0                       |
| `urn:x-nmos:format:mux`   | v1.1                       |

See [Use of URNs](#use-of-urns) below for additional requirements regarding their handling.

## Transport

A URN describing the protocol used to send data (video, audio, data etc.) over a network.

Note: From v1.3 onwards, permitted transport types are not versioned and are instead defined in the [Transports register](https://specs.amwa.tv/nmos-parameter-registers/branches/main/transports/) of the NMOS Parameter Registers. Prior to v1.3, the following table applies.

| **Permitted Value**              | **Valid From API Version** |
|----------------------------------|----------------------------|
| `urn:x-nmos:transport:rtp`       | v1.0                       |
| `urn:x-nmos:transport:rtp.mcast` | v1.0                       |
| `urn:x-nmos:transport:rtp.ucast` | v1.0                       |
| `urn:x-nmos:transport:dash`      | v1.0                       |

For example, an RTP Transmitter sending to a multicast group uses the transport `urn:x-nmos:transport:rtp.mcast`, but a receiver supporting both unicast and multicast presents the transport `urn:x-nmos:transport:rtp` to indicate its less restrictive state.

See [Use of URNs](#use-of-urns) below for additional requirements regarding their handling.

## Tags

A set of names and values providing a means to filter resources based on particular categorisations.

- Each tag is identified by a name. Note: Tag names can be defined in the [Tags register](https://specs.amwa.tv/nmos-parameter-registers/branches/main/tags/) of the NMOS Parameter Registers.
  The names within the `tags` object are expected to be unique, as per [RFC 8259 Section 4](https://tools.ietf.org/html/rfc8259#section-4).
- Each tag MAY have multiple values, unless additional constraints are defined for the specific name.

Filtering resources based on a name-value pair compares the value with each of the values for that name found in the resource `tags`.
The comparison SHOULD be case-insensitive following the Unicode Simple Case Folding specification.

**Example: Tags Format**

```json
{
  "tags": {
    "location": ["Salford", "Media City"],
    "studio": ["HQ1"],
    "recording": ["The Voice UK"]
  }
}
```

## Type (Devices)

A URN describing the role which a Device has within the production environment (such as camera, mixer, tally light etc.).

Note: From v1.3 onwards, permitted device types are not versioned and are instead defined in the [Device Types register](https://specs.amwa.tv/nmos-parameter-registers/branches/main/device-types/) of the NMOS Parameter Registers. Prior to v1.3, the following table applies.

| **Permitted Value**          | **Valid From API Version** |
|------------------------------|----------------------------|
| `urn:x-nmos:device:generic`  | v1.0                       |
| `urn:x-nmos:device:pipeline` | v1.0                       |

See [Use of URNs](#use-of-urns) below for additional requirements regarding their handling.

## Use of URNs

All Uniform Resource Names (URNs) specified within the scope of the NMOS specifications MUST use the namespace `urn:x-nmos:`. Manufacturers MAY use their own namespaces to indicate values of URN which are not currently defined within the NMOS namespace.

NMOS specification URNs use the following construction:

```
<URN-base>[.<subclassification>][/<version>]
```

where:

- the URN base is a sequence of one or more names delimited by `:` characters, beginning with the namespace `urn:x-nmos:`.
- the optional subclassification is the portion of the URN which follows the first occurrence of a `.` prior to any `/` character. By convention, URNs which begin `urn:x-nmos:` will never include a further `:` after the first occurrence of a `.`.
- the optional version is the portion of the URN which follows the first occurrence of a `/`, up to and including the remainder of the URN. By convention, URNs which begin `urn:x-nmos:` will format the version as `v<MAJOR>.<MINOR>` and SHOULD be handled as specified in [APIs](APIs.md).

A subclassification is more constrained than its URN base.  For example, the URN base `urn:x-nmos:transport:rtp` above has two subclassifications of `ucast` and `mcast`.

Further subclassifications might be defined for a URN base in the future.

Versioned URNs will be used to indicate specification versions.

For example, the URN `urn:x-nmos:control:sr-ctrl/v1.0` can be separated into a base `urn:x-nmos:control:sr-ctrl` and version `v1.0`.

API clients MUST be tolerant to URNs which have not yet been defined, but which might be added in later API versions.
