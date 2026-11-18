# Practice 11 - Notes

## Postman / curl

`GET https://jsonplaceholder.typicode.com/users` returned `200`, `Content-Type: application/json; charset=utf-8`, and **10 users**.

`GET https://jsonplaceholder.typicode.com/users/1` returned `200` with this shape:

### User

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `id` | number | `int` | no |
| `name` | string | `String` | no |
| `username` | string | `String` | no |
| `email` | string | `String` | no |
| `address` | object | `Address` | no |
| `phone` | string | `String` | no |
| `website` | string | `String?` | yes, model treats it as optional |
| `company` | object | `({String name, String catchPhrase})` | no |

### Address

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `street` | string | `String` | no |
| `suite` | string | `String` | no |
| `city` | string | `String` | no |
| `zipcode` | string | `String` | no |
| `geo` | object | `Geo` | no |

### Geo

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `lat` | string | `double` via `double.parse` | no |
| `lng` | string | `double` via `double.parse` | no |

### Company

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `name` | string | `String` | no |
| `catchPhrase` | string | `String` | no |
| `bs` | string | not modeled | no |

All fields were present in the real response. `website` is the only field the model allows to be `null`.

`GET /users/999` returned `404` with body `{}`.

`POST /users` returned `201` and the server added `"id": 11` to the body that was sent.

`GET /users?id=3` returned a **list with one user object**, not a single object.

## Two kinds of no network

| Case | What happened | Time |
| --- | --- | --- |
| No route / connection refused | `NoConnectionException`, Offline view | about 1.0 s |
| Connection accepted, no reply | `NoConnectionException`, Offline view | 10.0 s |

The second test used a local TCP listener that accepted the connection and stayed silent until the 10-second `timeout` fired. DevTools Network showed `GET https://localhost:4443/users` with no HTTP status and `Duration 10 s`.

## Endpoints used

- `GET /users` - list of 10 users
- `GET /users/1` - one user
- `GET /users/999` - 404
- `POST /users` - 201, server assigns `id`
