<h1>Kong plugin jwt-keycloak</h1>

A plugin for the [Kong Microservice API Gateway](https://konghq.com/solutions/gateway/) to validate access tokens issued by [Keycloak](https://www.keycloak.org/). It uses the [Well-Known Uniform Resource Identifiers](https://tools.ietf.org/html/rfc5785) provided by [Keycloak](https://www.keycloak.org/) to load [JWK](https://tools.ietf.org/html/rfc7517) public keys from issuers that are specifically allowed for each endpoint.

The biggest advantages of this plugin are that it supports:

* Rotating public keys
* Authorization based on token claims:
    * `scope`
    * `realm_access`
    * `resource_access`
* Matching Keycloak users/clients to Kong consumers

If you have any suggestion or comments, please feel free to open an issue on this GitHub page.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Tested and working for](#tested-and-working-for)
- [Installation](#installation)
  - [Using luarocks](#using-luarocks)
  - [From source](#from-source)
    - [Packing the rock](#packing-the-rock)
    - [Installing the rock](#installing-the-rock)
  - [Enabling plugin](#enabling-plugin)
  - [Changing plugin priority](#changing-plugin-priority)
  - [Examples](#examples)
- [Usage](#usage)
  - [Enabling on endpoints](#enabling-on-endpoints)
    - [Service](#service)
    - [Route](#route)
    - [Globally](#globally)
  - [Parameters](#parameters)
  - [Example](#example)
  - [Caveats](#caveats)
- [Testing](#testing)
  - [Setup before tests](#setup-before-tests)
  - [Running tests](#running-tests)
  - [Useful debug commands](#useful-debug-commands)

## Tested and working for

| Kong Version |   Tests passing    |
| ------------ | :----------------: |
| 0.13.x       |        :x:         |
| 0.14.x       |        :x:         |
| 1.0.x        | :white_check_mark: |
| 1.1.x        | :white_check_mark: |
| 1.2.x        | :white_check_mark: |
| 1.3.x        | :white_check_mark: |
| 1.4.x        | :white_check_mark: |

| Keycloak Version |   Tests passing    |
| ---------------- | :----------------: |
| 3.X.X            | :white_check_mark: |
| 4.X.X            | :white_check_mark: |
| 5.X.X            | :white_check_mark: |
| 6.X.X            | :white_check_mark: |
| 7.X.X            | :white_check_mark: |

## Installation

### Using luarocks

```bash
luarocks install kong-plugin-jwt-keycloak
```

### From source

#### Packing the rock

```bash
export PLUGIN_VERSION=1.1.0-1
luarocks make
luarocks pack kong-plugin-jwt-keycloak ${PLUGIN_VERSION}
```

#### Installing the rock

```bash
export PLUGIN_VERSION=1.1.0-1
luarocks install jwt-keycloak-${PLUGIN_VERSION}.all.rock
```

### Enabling plugin

Set enabled kong enabled plugins, i.e. with environmental variable: `KONG_PLUGINS="bundled,jwt-keycloak"`

### Changing plugin priority

In some cases you might want to change the execution priority of the plugin. You can do that by setting an environmental variable: `JWT_KEYCLOAK_PRIORITY="900"`

### Examples

See [Dockerfile](./Dockerfile) or [luarocks Dockerfile](./luarocks.Dockerfile) for more concrete examples.

## Usage

### Enabling on endpoints

The same principle applies to this plugin as the [standard jwt plugin that comes with kong](https://docs.konghq.com/hub/kong-inc/jwt/). You can enable it on service, routes and globally.

#### Service

```bash
curl -X POST http://localhost:8001/services/{service}/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allowed_iss=http://localhost:8080/auth/realms/master"
```

#### Route
```bash
curl -X POST http://localhost:8001/routes/{route_id}/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allowed_iss=http://localhost:8080/auth/realms/master"
```

#### Globally

```bash
curl -X POST http://localhost:8001/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allowed_iss=http://localhost:8080/auth/realms/master"
```

### Parameters

| Parameter                              | Requied | Default           | Description                                                                                                                                                                                                                                                                                                                                                                              |
| -------------------------------------- | ------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                                   | yes     |                   | The name of the plugin to use, in this case `keycloak-jwt`.                                                                                                                                                                                                                                                                                                                              |
| service_id                             | semi    |                   | The id of the Service which this plugin will target.                                                                                                                                                                                                                                                                                                                                     |
| route_id                               | semi    |                   | The id of the Route which this plugin will target.                                                                                                                                                                                                                                                                                                                                       |
| enabled                                | no      | `true`            | Whether this plugin will be applied.                                                                                                                                                                                                                                                                                                                                                     |
| config.uri_param_names                 | no      | `jwt`             | A list of querystring parameters that Kong will inspect to retrieve JWTs.                                                                                                                                                                                                                                                                                                                |
| config.cookie_names                    | no      |                   | A list of cookie names that Kong will inspect to retrieve JWTs.                                                                                                                                                                                                                                                                                                                          |
| config.claims_to_verify                | no      | `exp`             | A list of registered claims (according to [RFC 7519](https://tools.ietf.org/html/rfc7519)) that Kong can verify as well. Accepted values: `exp`, `nbf`.                                                                                                                                                                                                                                  |
| config.anonymous                       | no      |                   | An optional string (consumer uuid) value to use as an “anonymous” consumer if authentication fails. If empty (default), the request will fail with an authentication failure `4xx`. Please note that this value must refer to the Consumer `id` attribute which is internal to Kong, and not its `custom_id`.                                                                            |
| config.run_on_preflight                | no      | `true`            | A boolean value that indicates whether the plugin should run (and try to authenticate) on `OPTIONS` preflight requests, if set to false then `OPTIONS` requests will always be allowed.                                                                                                                                                                                                  |
| config.maximum_expiration              | no      | `0`               | An integer limiting the lifetime of the JWT to `maximum_expiration` seconds in the future. Any JWT that has a longer lifetime will rejected (HTTP 403). If this value is specified, `exp` must be specified as well in the `claims_to_verify` property. The default value of `0` represents an indefinite period. Potential clock skew should be considered when configuring this value. |
| config.algorithm                       | no      | `RS256`           | The algorithm used to verify the token’s signature. Can be `HS256`, `HS384`, `HS512`, `RS256`, or `ES256`.                                                                                                                                                                                                                                                                               |
| config.allowed_iss                     | yes     |                   | A list of allowed issuers for this route/service/api.                                                                                                                                                                                                                                                                                                                                    |
| config.iss_key_grace_period            | no      | `10`              | An integer that sets the number of seconds until public keys for an issuer can be updated after writing new keys to the cache. This is a guard so that the Kong cache will not invalidate every time a token signed with an invalid public key is sent to the plugin.                                                                                                                    |
| config.well_known_template             | false   | *see description* | A string template that the well known endpoint for keycloak is created from. String formatting is applied on the template and `%s` is replaced by the issuer of the token. Default value is `%s/.well-known/openid-configuration`                                                                                                                                                        |
| config.scope                           | no      |                   | A list of scopes the token must have to access the api, i.e. `["email"]`. The token only has to have one of the listed scopes to be authorized.                                                                                                                                                                                                                                          |
| config.roles                           | no      |                   | A list of roles of current client the token must have to access the api, i.e. `["uma_protection"]`. The token only has to have one of the listed roles to be authorized.                                                                                                                                                                                                                 |
| config.realm_roles                     | no      |                   | A list of realm roles (`realm_access`) the token must have to access the api, i.e. `["offline_access"]`. The token only has to have one of the listed roles to be authorized.                                                                                                                                                                                                            |
| config.client_roles                    | no      |                   | A list of roles of a different client (`resource_access`) the token must have to access the api, i.e. `["account:manage-account"]`. The format for each entry should be `<CLIENT_NAME>:<ROLE_NAME>`. The token only has to have one of the listed roles to be authorized.                                                                                                                |
| config.consumer_match                  | no      | `false`           | A boolean value that indicates if the plugin should find a kong consumer with `id`/`custom_id` that equals the `consumer_match_claim` claim in the access token.                                                                                                                                                                                                                         |
| config.consumer_match_claim            | no      | `azp`             | The claim name in the token that the plugin will try to match the kong `id`/`custom_id` against.                                                                                                                                                                                                                                                                                         |
| config.consumer_match_claim_custom_id  | no      | `false`           | A boolean value that indicates if the plugin should match the `consumer_match_claim` claim against the consumers `id` or `custom_id`. By default it matches the consumer against the `id`.                                                                                                                                                                                               |
| config.consumer_match_ignore_not_found | no      | `false`           | A boolean value that indicates if the request should be let through regardless if the plugin is able to match the request to a kong consumer or not.                                                                                                                                                                                                                                     |

### Example

Create service and add the plugin to it, and lastly create a route:

```bash
curl -X POST http://localhost:8001/services \
    --data "name=mockbin-echo" \
    --data "url=http://mockbin.org/echo"

curl -X POST http://localhost:8001/services/mockbin-echo/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allowed_iss=http://localhost:8080/auth/realms/master"

curl -X POST http://localhost:8001/services/mockbin-echo/routes \
    --data "paths=/" 
```

Then you can call the API:

```bash
curl http://localhost:8000/
```

This should give you a 401 unauthorized. But if we call the API with a token:

```bash
export CLIENT_ID=<YOUR_CLIENT_ID>
export CLIENT_SECRET=<YOUR_CLIENT_SECRET>

export TOKENS=$(curl -s -X POST \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "grant_type=client_credentials" \
-d "client_id=${CLIENT_ID}" \
-d "client_secret=${CLIENT_SECRET}" \
http://localhost:8080/auth/realms/master/protocol/openid-connect/token)

export ACCESS_TOKEN=$(echo ${TOKENS} | jq -r ".access_token")

curl -H "Authorization: Bearer ${ACCESS_TOKEN}" http://localhost:8000/ \
    --data "plugin=working"
```

This should give you the response: `plugin=working`

### Caveats

To verify token issuers, this plugin needs to be able to access the `<ISSUER_REALM_URL>/.well-known/openid-configuration` and `<ISSUER_REALM_URL>/protocol/openid-connect/certs` endpoints of keycloak. If you are getting the error `{ "message": "Unable to get public key for issuer" }` it is probably because for some reason the plugin is unable to access these endpoints.

## Testing

Requires:
* make
* docker

**Because testing uses docker host networking it does not work on MacOS**

### Setup before tests

```bash
make keycloak-start
```

### Running tests

```bash
make test-unit # Unit tests
make test-integration # Integration tests with postgres
make test-integration KONG_DATABASE=cassandra # Integration tests with cassandra
make test # All test with postgres
make test KONG_DATABASE=cassandra # All test with cassandra
make test-all # All test with cassandra and postgres and multiple versions of kong
```

### Useful debug commands

```bash
make kong-log # For proxy logs
make kong-err-proxy # For proxy error logs
make kong-err-admin # For admin error logs
```