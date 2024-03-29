# APIs: Query Parameters

_(c) AMWA 2016, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

The Query API supports a range of query string parameters which MAY be used as part of `GET` requests, or within WebSocket subscriptions.

The following document describes the expected usage and behaviour of these query parameters alongside the RAML specification in order to aid implementers. A description of each individual query parameter is included within the RAML.

## Pagination

Query APIs SHOULD support pagination of their API resources where the `paged` trait is specified in the RAML documentation. A `501` (Not Implemented) HTTP status code MUST be returned where pagination is attempted against a Query API which does not implement it. Pagination is not used by WebSocket subscriptions.

Query API clients MUST detect whether pagination is being used by examining the HTTP response headers for `X-Paging-Limit` which MUST be returned in all cases where pagination is in use.

The registry which backs the Query API SHOULD maintain a `creation` and `update` timestamp alongside each registered resource. These values SHOULD NOT be returned to API clients in the response body, but will be made available via headers and used as pagination cursors.

To ensure that pagination does not result in resources being skipped, there SHOULD NOT be duplicate creation or update timestamps stored against resources of the same type (Node, Source, Flow, etc.). It is RECOMMENDED that these timestamps are stored with nanosecond resolution using a TAI timebase, which will allow clients to navigate collections based on a common understanding of time.

The choice to page based on `creation` or `update` timestamp depends on the client's intended use of the data:

- Paging based on `creation` time from the start of a collection provides the best mechanism to identify all resources held in a registry.
- Paging based on `update` time from the end of a collection provides the best mechanism to watch for changing resources in the case that WebSocket subscriptions are not available.

Paging through a collection for a second time, using the same cursors as previously SHOULD NOT result in new data appearing in the response payloads when using `creation` ordering, provided the requested paging times are less than or equal to the maximum paging time held in the registry. However, note that as the registry is dynamic and resources could be updated or deleted a given cursor MAY return fewer results than it did previously. When using `update` ordering and a query filter, new data MAY appear when cursors are used for a second time.

When query parameters which perform filtering are used at the same time as paging, the filters MUST be applied by the implementation before applying paging parameters to the resulting data set.

A server MAY choose its own default value for paging limit (see Example 1).

Where both `since` and `until` parameters are specified, the `since` value takes precedence where a resulting data set is constrained by the server's value of `limit` (see Example 5).

Servers SHOULD return a `Link` header with `prev` and `next` links in all responses and MAY include `first` and `last` links.

### Examples

The following examples show pagination for a set of registered data. In order to avoid displaying full resource representations, the only data listed here is the `update` timestamp associated with each registered record. The same procedures can be applied where `creation` timestamps and the `paging.order=create` query parameter are used instead.

Where a paging limit is not specified in a request the server's default is used.

**Sample Data: Registered Node Update Timestamps (Comma-Separated)**

```json
[0:1, 0:2, 0:3, 0:4, 0:5, 0:6, 0:7, 0:8, 0:9, 0:10, 0:11, 0:12, 0:13, 0:14, 0:15, 0:16, 0:17, 0:18, 0:19, 0:20]
```

Each of the above corresponds to the update timestamp of a corresponding Node, in the format `<seconds>:<nanoseconds>` and displayed in ascending order. These will be used throughout the following examples.

Response payloads in the examples will show these values, but in a real implementation would be replaced by the corresponding JSON objects for the Nodes or other resources being queried.

**Example 1: Initial `/nodes` Request**

In this example there are no query parameters used in the request, but as the Query API supports pagination it returns a subset of the results with headers identifying how to page further into the collection.

***Request***

```http
GET /x-nmos/query/v1.1/nodes
```

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:20&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:10&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:10
X-Paging-Until: 0:20
```

Payload Resources

```json
[
  0:20,
  0:19,
  0:18,
  0:17,
  0:16,
  0:15,
  0:14,
  0:13,
  0:12,
  0:11
]
```

***Notes***

- The data set returned when no `paging.since` or `paging.until` parameters are specified MUST be from the most recently updated (or created) resources in the collection, returned in descending order.
- The `X-Paging-` headers identify properties of the collection of data returned in the response. These parameters can be used to construct a URL which would return the same set of bounded data on consecutive requests, for example:

  ```
  /x-nmos/query/v1.1/nodes?paging.since=0:10&paging.until=0:20
  ```

- The `Link` header identifies the `next` and `prev` cursors which an application can use to make its next requests.
  An implementation MAY also provide `first` and `last` cursors to identify the beginning and end of the collection.
  The `last` cursor URL returns the most recently updated (or created) resources, as when no `paging.since` or `paging.until` parameters are specified.
  The `first` cursor URL returns the least recently updated (or created) resources, as when `paging.since=0:0` is specified.

**Example 2: Request With Custom Limit**

This request is similar to Example 1, but the client has chosen to use a custom page size limit.

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.limit=5
```

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:20&paging.limit=5>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:15&paging.limit=5>; rel="prev"
X-Paging-Limit: 5
X-Paging-Since: 0:15
X-Paging-Until: 0:20
```

Payload Resources

```json
[
  0:20,
  0:19,
  0:18,
  0:17,
  0:16
]
```

***Notes***

- In this case the server has accepted the client's paging size limit request. If the client had requested a page size which the server was unable to honour, the actual page size used would be returned in `X-Paging-Limit`.

**Example 3: Request With Since Parameter**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.since=0:4
```

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:14&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:4&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:4
X-Paging-Until: 0:14
```

Payload Resources

```json
[
  0:14,
  0:13,
  0:12,
  0:11,
  0:10,
  0:9,
  0:8,
  0:7,
  0:6,
  0:5
]
```

**Example 4: Request With Until Parameter**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.until=0:16
```

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:16&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:6&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:6
X-Paging-Until: 0:16
```

Payload Resources

```json
[
  0:16,
  0:15,
  0:14,
  0:13,
  0:12,
  0:11,
  0:10,
  0:9,
  0:8,
  0:7
]
```

**Example 5: Request With Since & Until Parameters**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.since=0:4&paging.until=0:16
```

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:14&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:4&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:4
X-Paging-Until: 0:14
```

Payload Resources

```json
[
  0:14,
  0:13,
  0:12,
  0:11,
  0:10,
  0:9,
  0:8,
  0:7,
  0:6,
  0:5
]
```

***Notes***

- Whilst both `since` and `until` are specified, as this server example has a default paging limit of `10`, the `since` parameter  takes precedence. As a result of this the value of `X-Paging-Until` is lower than requested and a further request can be made to retrieve any remaining data.

### Edge Cases

When a client requests data which falls at the extreme ends of the stored data set it can be less clear what values are expected to be returned in the `X-Paging-Limit` and `X-Paging-Since` headers. The following examples are intended to clarify these cases.

Where a paging limit is not specified in a request the server's default is used.

**Example 1: Client request occurs at the beginning of the data set**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.until=0:20
```

In this case, assume that there are stored records for `0:21` and `0:22` but no earlier.

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:20&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:0&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:0
X-Paging-Until: 0:20
```

Payload Resources

```json
[]
```

**Example 2: Client request occurs at the end of the data set**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?paging.since=0:20
```

In this case, assume that there are stored records for `0:19` and `0:20` but no later.

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.since=0:20&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?paging.until=0:20&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:20
X-Paging-Until: 0:20
```

Payload Resources

```json
[]
```

***Notes:***

- In this situation the client is expected to re-perform the same request (as specified in the `next` cursor) until data is returned. If the client were to increment the value of `since` requested it would be in danger of moving ahead of the current time and missing records.

**Example 3: Client request includes a query parameter resulting in a single result, but no paging parameters**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?label=My%20Node
```

In this case, assume that the most recently created or updated Node held in the registry has a paging value of `0:20` associated with it. Also assume that the Node with label `My Node` has a paging time of `0:15`.

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?label=My%20Node&paging.since=0:20&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?label=My%20Node&paging.until=0:0&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:0
X-Paging-Until: 0:20
```

Payload Resources

```json
[
  0:15
]
```

**Example 4: Client request includes a query parameter resulting in a no result, with no paging parameters**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?label=My%20Invalid%20Node
```

In this case, assume that the most recently created or updated Node held in the registry has a paging value of `0:20` associated with it.

***Response***

Headers

```http
Link: <http://api.example.com/x-nmos/query/v1.1/nodes/?label=My%20Invalid%20Node&paging.since=0:20&paging.limit=10>; rel="next", <http://api.example.com/x-nmos/query/v1.1/nodes/?label=My%20Invalid%20Node&paging.until=0:0&paging.limit=10>; rel="prev"
X-Paging-Limit: 10
X-Paging-Since: 0:0
X-Paging-Until: 0:20
```

Payload Resources

```json
[]
```

## Downgrade Queries

Query APIs SHOULD support downgrade queries against their API resources where the `downgrade` trait is specified in the RAML documentation. A `501` (Not Implemented) HTTP status code MUST be returned where a downgrade query is attempted against a Query API which does not implement it.

In order to streamline upgrades from one API version to another a Query API MAY sit in front of a registry which holds registered data matching multiple API versions' schemas. By default the Query API MUST only return data matching the API version specified in the request URL, however downgrade queries permit old-versioned responses to be provided to clients which are confident that they can handle any missing attributes between the specified API versions.

Downgrades MUST only be performed between minor API versions as major versions might remove or re-purpose attributes. Clients which support multiple major API versions SHOULD retrieve this data via multiple HTTP requests or WebSocket subscriptions.

### Examples

**Example 1: No Downgrade Parameter**

***Request***

```http
GET /x-nmos/query/v1.1/nodes
```

***Response***

- Returns all Nodes held in the registry which match the v1.1 schema.
- Returns Nodes with versions greater than or equal to v1.2, and less than v2.0. These Nodes MUST have all non-v1.1 keys stripped by the Query API before they are returned.

**Example 2: Downgrade From v1.1 to v1.0**

***Request***

```http
GET /x-nmos/query/v1.1/nodes?query.downgrade=v1.0
```

***Response***

- Returns all Nodes held in the registry which match the v1.1 schema.
- Returns Nodes with versions greater than or equal to v1.2, and less than v2.0. These Nodes MUST have all non-v1.1 keys stripped by the Query API before they are returned.
- Returns all Nodes which are registered in v1.0 format.

**Example 3: Downgrade From v1.3 to v1.1**

***Request***

```http
GET /x-nmos/query/v1.3/flows?query.downgrade=v1.1
```

***Response***

- Returns all Flows held in the registry which match the v1.3 schema.
- Returns Flows with versions greater than or equal to v1.4, and less than v2.0. These Flows MUST have all non-v1.3 keys stripped by the Query API before they are returned.
- Returns all Flows which are registered in v1.2 or v1.1 format.

### Invalid Examples

**Invalid Example 1: Downgrade Between Major API Versions**

***Request***

```http
GET /x-nmos/query/v3.0/flows?query.downgrade=v1.0
```

***Response***

- Returns an HTTP `400` (Bad Request) error code as downgrade queries MUST NOT be performed between major API versions.

## Basic Queries

Query APIs SHOULD support basic queries against their API resources. A `501` (Not Implemented) HTTP status code MUST be returned where a basic query is attempted against a Query API which does not implement it.

Basic queries make use of standard HTTP `GET` query parameters in the form `?key1=value1&key2=value2`. Keys match any attribute which the API schemas indicate could be returned by a given resource.

Any attribute which could be returned by a particular API resource SHOULD be available to use as a query parameter, however the RAML documentation only explicitly identifies core attributes under `queryParameters`.

If a query parameter is requested which does not match an attribute found in any resource, an empty result set MUST be returned.

- Querying Within Objects
  - Querying using attributes of objects is permitted via the use of a `.` separator. For example, the `/receivers` resource can be queried with:
  
    ```
    ?subscription.sender_id=2683ad14-642f-459d-a169-ef91c76cec6b
    ```

- Querying Within Arrays
  - Querying using attributes of objects held within arrays is permitted via the use of a `.` separator. For example, the `/nodes` resource can be queried with:
  
    ```
    ?services.type=urn:x-manufacturer:service:tally
    ```
    
    More advanced queries within arrays might require use of the Resource Query Language `in()` operator.

### Examples

**Example 1: Basic Query Using One Parameter**

***Request***

```http
GET /x-nmos/query/v1.0/senders?transport=urn:x-nmos:transport:rtp
```

***Response***

- Returns all Sender objects which have an attribute `transport` which exactly matches the string `urn:x-nmos:transport:rtp`.

**Example 2: Basic Query Using Two Parameters**

***Request***

```http
GET /x-nmos/query/v1.0/sources?format=urn:x-nmos:format:video&device_id=9126cc2f-4c26-4c9b-a6cd-93c4381c9be5
```

***Response***

- Returns all Source objects which have an attribute of `format` which exactly matches `urn:x-nmos:format:video` and a `device_id` attribute which exactly matches `9126cc2f-4c26-4c9b-a6cd-93c4381c9be5`.

**Example 3: Querying Within Objects**

***Request***

```http
GET /x-nmos/query/v1.0/flows?tags.studio=HQ1
```

***Response***

- Returns all Flows which have a `tags` attribute with a key of `studio`. The value of `tags.studio` (which is an array in this case, see Flow schema) MUST contain `HQ1` as one of its entries.

**Example 4: Querying Within Arrays**

***Request***

```http
GET /x-nmos/query/v1.0/nodes?services.type=urn:x-manufacturer:service:myservice
```

***Response***

- The schema defines a Node's `services` as an array of objects, where `type` is a key in these inner objects. As a result, this query returns all Nodes where one of these service objects has a `type` of `urn:x-manufacturer:service:myservice`.

### Invalid Examples

**Invalid Example 1: Duplicate Query Parameters**

***Request***

```http
GET /x-nmos/query/v1.0/flows?tags.location=Salford&tags.location=London
```

***Response***

- This query specifies two matching query parameters with different values. As different programming frameworks might not make both of these values available, this is an invalid query for which the response is not defined and might vary by implementation. The next section provides a means of achieving the desired query.

## Advanced (RQL) Queries (OPTIONAL)

Query APIs MAY support Resource Query Language (RQL, <https://github.com/persvr/rql/>) queries against their API resources where the `rql` trait is specified in the RAML documentation. A `501` (Not Implemented) HTTP status code MUST be returned where an RQL query is attempted using RQL functions or operators which are not supported by a Query API.

RQL SHOULD be formatted in the normalised form as opposed to using FIQL syntax, and passed via the query string using a `query.rql=...` query parameter.

Querying within objects and arrays is performed as in the Basic Queries case by using the `.` separator.

When an RQL query is specified, the Basic Queries format MAY be ignored in order to simplify implementation.

Note that as RQL permits the definition of very complex queries, the server MAY return a `400` (Bad Request) error code to indicate that it is refusing to action the client's request due to the query's complexity.

### Constraints

Not all RQL operators will be suitable for use with a Query API. It is suggested that the following operators are supported, however these are not mandated and implementations MAY choose to support their own subset.

1. Functions: `in()`, `out()`, `select()`

2. Logical Operators: `and()`, `or()`, `not()`

3. Relational Operators: `eq()`, `ne()`, `gt()`, `ge()`, `lt()`, `le()`

Note: It is suggested that `sort()` and `limit()` are not implemented as paging and associated limits are specified directly by other query parameters.

### Examples

**Example 1: Simple Query**

***Request***

```http
GET /x-nmos/query/v1.1/senders?query.rql=eq(transport,urn%3Ax-nmos%3Atransport%3Artp)
```

***Response***

- Returns all Sender objects which have an attribute `transport` which exactly matches the string `urn:x-nmos:transport:rtp`. This response matches that of Example 1 in basic querying.

**Example 2: Advanced Query**

***Request***

```http
GET /x-nmos/query/v1.1/sources?query.rql=and(eq(format,urn%3Ax-nmos%3Aformat%3Avideo),in(tags.location,(Salford,London)))
```

***Response***

- Returns all Sources which have a `format` attribute equal to `urn:x-nmos:format:video` and a `tags` attribute with a key of `location`, which has values of `Salford` or `London`.

## Ancestry Queries (OPTIONAL)

Query APIs MAY support Source and Flow ancestry queries against their API resources where the `ancestry` trait is specified in the RAML documentation. A `501` (Not Implemented) HTTP status code MUST be returned where an ancestry query is attempted against a Query API which does not implement it.

Sources and Flows list their `parents` in an array. A Query API implementing ancestry tracking MAY be queried using `query.ancestry_...` query parameters in order to identify parents or children of a given Source or Flow.

### Examples

**Example 1: Children Of A Source**

***Request***

```http
GET /x-nmos/query/v1.1/sources?query.ancestry_id=c1398579-15bc-468e-91ec-df5bbefe1cd3&query.ancestry_type=children
```

***Response***

Headers

```http
X-Ancestry-Generations: 4
```

Payload

- Returns Sources which list an ID of `c1398579-15bc-468e-91ec-df5bbefe1cd3` in their `parents` attribute array. These children are the first generation descendants.
- For each first generation descendant found, the ID of these Sources is used to look up the next generation by the `parents` arrays of further Sources.
- This process continues up to the generation limit returned in the `X-Ancestry-Generations` header. The server MAY refuse to honour a requested `query.ancestry_generations` value using a `400` (Bad Request) error code if it is deemed to be too resource intensive.

***Notes***

- Responses do not include the Source with ID specified in the `ancestry_id` parameter.

**Example 2: Parents Of A Flow**

***Request***

```http
GET /x-nmos/query/v1.1/flows?query.ancestry_id=ad14888a-3a98-444c-8aa8-4d87b77cbaa1&query.ancestry_type=parents&query.ancestry_generations=2
```

***Response***

Headers

```http
X-Ancestry-Generations: 2
```

Payload

- Returns Flows which are listed in the `parents` array of the Flow identified by the ID `ad14888a-3a98-444c-8aa8-4d87b77cbaa1`. These parents are the first generation ancestors.
- For each first generation ancestor found, their `parents` array is used to identify the next generation of ancestors to be returned.
- This process continues up to the generation limit returned in the `X-Ancestry-Generations` header (in this case limited to 2 by a query parameter). The server MAY refuse to honour a requested `query.ancestry_generations` value using a `400` (Bad Request) error code if it is deemed to be too resource intensive.

***Notes***

- Responses do not include the Flow with ID specified in the `ancestry_id` parameter.
