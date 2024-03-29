# Behaviour: Querying

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

The Query API provides a read-only interface to the Nodes and their sub-resources which are currently held in the registry. Monitoring of these resources can be performed using the HTTP API, or using a WebSocket connection ([RFC 6455](https://tools.ietf.org/html/rfc6455)), which is suggested for most applications.

## API Resources

Additional requirements for behaviour associated with particular attributes, beyond what is specified in the schemas, are documented below.

### Subscriptions

`secure`: Indicates whether the WebSocket connection is encrypted (`ws://` vs. `wss://`). If the client does not specify in the request to create the Subscription, the server SHOULD assign the value `false` if the API is being presented via HTTP, and `true` for HTTPS. Query API clients MAY specify the opposite value in requests for Subscriptions, however they will receive a `400` (Bad Request) response code unless the Query API explicitly supports a mismatch between encrypted and insecure HTTP and WebSocket connections.

`authorization`: Indicates whether the WebSocket connection requires authorization in order to connect. Use of authorization is likely to be a deployment decision and be the same for all Subscriptions exposed from a single Query API, and for the HTTP API itself. Query API clients MAY specify a requested value for this attribute, but in most circumstances this will result in a `400` (Bad Request) response code if the Query API is operating in the opposite mode.

`persist`: Indicates whether the Subscription is persistent or non-persistent.
The Query API MAY remove any Subscriptions with `persist` set to `false` that no longer have WebSocket connections. The Query API MUST NOT acknowledge HTTP `DELETE` requests for Subscriptions running in this non-persistent mode, instead issuing an HTTP `403` (Forbidden) response.
If a persistent Subscription has been requested by the client, this MUST NOT be cleaned up automatically by the Query API, even if all clients have disconnected. If an HTTP `DELETE` is issued prior to all WebSocket connections being closed, they SHOULD be forcibly closed by the server.

## Creating a WebSocket Subscription

In order to connect to a WebSocket, a client first requests a Subscription of a particular resource type and with particular query parameters by performing a `POST` request to the `/subscriptions` resource, as defined in the [Query API](../APIs/QueryAPI.raml) specification. Use of `GET` requests to find existing suitable Subscriptions is strongly discouraged.

Upon receiving a request for a new Subscription, the Query API MAY return an existing Subscription to the user, if it matches the requested attributes. If a relevant Subscription does not exist, a new one SHOULD be created.

As for the HTTP API endpoints, a `501` (Not Implemented) HTTP status indicates that the requested query parameters are not supported by this Query API.

There is no mandated URL base path for servers to use to provide WebSocket connections. Instead clients SHOULD observe the value of `ws_href` which is returned by their Subscription request in order to identify what to connect to.

Query APIs MAY additionally support the HTTP protocol upgrade mechanism on list resources such as `/nodes` to transition an HTTP `GET` request to a WebSocket connection, but this is not mandated. In cases where this is performed, a corresponding entry in `/subscriptions` for a non-persistent Subscription MUST also be created with matching attributes.

### WebSocket Messages

The server provides a client with the current state of the contents of the registry at the time of their WebSocket connection, using messages which are known as data Grains. It subsequently notifies clients of any changes via additional data Grain messages.

In the Query API usage, the `source_id` in each message identifies the Query API instance. The `flow_id` is the `id` of the Subscription under the `/subscriptions` HTTP resource.

The timestamps used in data Grain messages are as follows:

- `creation_timestamp`: The creation time of the Grain metadata which wraps the payload being exchanged.
- `origin_timestamp`: The capture or creation time of the payload being exchanged.
- `sync_timestamp`: Matches the `origin_timestamp` at the point of capture or creation. (This timestamp relates this payload to others which could take different processing paths. This can persist through processing devices which modify the Grain payload.)

The three timestamps MAY be identical. For more details of the timing model used in NMOS specifications, see [MS-04](https://specs.amwa.tv/ms-04/).

The `rate` and `duration` attributes MAY be ignored by clients as the messages being exchanged represent events in the registry and do not adhere to a defined rate or duration.

Each Grain MAY contain one or more objects in its `data` array. Each event object identifies a change to a single Source, Flow or other resource as identified by the Grain `topic` and the event `path`, which together correspond to the resource path in the Query API.

A data Grain message related to the subscription `e223e6f3-de75-4855-bd19-b83774e31689`, with an event corresponding to the Query API resource `/flows/b58aae65-1913-4f7b-aae2-2377446dd639`.

```json
{
  "grain_type": "event",
  "source_id": "<id_of_query_api_instance>",
  "flow_id": "e223e6f3-de75-4855-bd19-b83774e31689",
  "origin_timestamp": "<ts_secs>:<ts_nsecs>",
  "sync_timestamp": "<ts_secs>:<ts_nsecs>",
  "creation_timestamp": "<ts_secs>:<ts_nsecs>",
  "rate": {
    "numerator": 0,
    "denominator": 1
  },
  "duration": {
    "numerator": 0,
    "denominator": 1
  },
  "grain": {
    "type": "urn:x-nmos:format:data.event",
    "topic": "/flows/",
    "data": [
      {
        "path": "b58aae65-1913-4f7b-aae2-2377446dd639",
        ...
      },
      ...
    ]
  }
}
```

A schema for the WebSocket messages is available [here](../APIs/schemas/queryapi-subscriptions-websocket.json).

#### Resource Added Events

Event data containing only a `post` attribute signifies creation of a resource.

```json
  "grain": {
    "type": "urn:x-nmos:format:data.event",
    "topic": "/flows/",
    "data": [
      {
        "path": "b58aae65-1913-4f7b-aae2-2377446dd639",
        "post": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_flow_name",
          "description": "my flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        }
      },
      ...
    ]
  }
```

#### Resource Removed Events

Event data containing only a `pre` attribute signifies deletion of a resource.

```json
  "grain": {
    "type": "urn:x-nmos:format:data.event",
    "topic": "/flows/",
    "data": [
      {
        "path": "b58aae65-1913-4f7b-aae2-2377446dd639",
        "pre": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_flow_name",
          "description": "my flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        }
      },
      ...
    ]
  }
```

#### Resource Modified Events

Event data containing both `pre` and `post` attributes signifies modification of a resource. All attributes of the resource MUST be specified (i.e. not just those that have changed).

```json
  "grain": {
    "type": "urn:x-nmos:format:data.event",
    "topic": "/flows/",
    "data": [
      {
        "path": "b58aae65-1913-4f7b-aae2-2377446dd639",
        "pre": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_flow_name",
          "description": "my flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        },
        "post": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_new_flow_name",
          "description": "my new flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        }
      },
      ...
    ]
  }
```

#### Resource Unchanged (Sync) Events

Event data containing both  `pre` and  `post` where the contents of  `pre` and  `post` are identical. This is used in initial synchronisation messages that ensure the client has received all data for a given topic.

```json
  "grain": {
    "type": "urn:x-nmos:format:data.event",
    "topic": "/flows/",
    "data": [
      {
        "path": "b58aae65-1913-4f7b-aae2-2377446dd639",
        "pre": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_flow_name",
          "description": "my flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        },
        "post": {
          "id": "b58aae65-1913-4f7b-aae2-2377446dd639",
          "label": "my_flow_name",
          "description": "my flow description",
          "source_id": "0e1b33f-6cfb-423e-b777-23efe0f539f4",
          "format": "urn:x-nmos:format:video"
        }
      },
      {
        "path": "e759c3f0-8eed-4344-932a-5eb1c40a2d41",
        "pre": {
          "id": "e759c3f0-8eed-4344-932a-5eb1c40a2d41",
          "label": "another_flow_name",
          "description": "another flow description",
          "source_id": "d7f43929-30c7-4847-a0f8-0242b82002d8",
          "format": "urn:x-nmos:format:audio"
        },
        "post": {
          "id": "e759c3f0-8eed-4344-932a-5eb1c40a2d41",
          "label": "another_flow_name",
          "description": "another flow description",
          "source_id": "d7f43929-30c7-4847-a0f8-0242b82002d8",
          "format": "urn:x-nmos:format:audio"
        }
      },
      ...
    ]
  }
```

#### Handling Query Parameters

WebSocket subscriptions support query parameters in a similar way as the corresponding HTTP API endpoints. Query parameters are specified in a `params` attribute rather than the query string.
The [Basic Queries](APIs%20-%20Query%20Parameters.md#basic-queries) documentation includes the examples:

```http
GET /x-nmos/query/v1.0/sources?format=urn:x-nmos:format:video&device_id=9126cc2f-4c26-4c9b-a6cd-93c4381c9be5
```

```http
GET /x-nmos/query/v1.0/flows?tags.studio=HQ1
```

The `POST` requests to create equivalent Subscriptions would have:

```json
  "resource_path": "/sources",
  "params": {
    "format": "urn:x-nmos:format:video",
    "device_id": "9126cc2f-4c26-4c9b-a6cd-93c4381c9be5"
  }
```

```json
  "resource_path": "/flows",
  "params": {
    "tags.studio": "HQ1"
  }
```

Subscriptions MUST inform clients when resources begin to match, or no longer match, the given query parameters. For example:

- If a Flow (or other resource) has a `tag` removed causing it to no longer match the query parameters for a WebSocket subscription, the client MUST be issued a 'Resource Removed Event' as if this resource had been deleted from the registry.
- If a Flow (or other resource) has a `tag` added causing it to match a query parameter where it didn't match them previously, the client MUST be issued a 'Resource Added Event' as if this resource had been freshly created in the registry.

## Referential Integrity

The `senders` and `receivers` arrays in Device resources are now deprecated, as referential integrity issues could occur if:

- the arrays contain Senders or Receivers that belong to a Device, but have not yet been registered themselves, or:
- Senders and Receivers have been registered but do not yet appear in the arrays.

Use of these arrays is discouraged and Node/Query API clients SHOULD instead discover attached Senders/Receivers by filtering Senders and Receivers on `device_id`.
