# Kong plugin jwt-keycloak

# Installation

To install do the following:
* Copy the plugin folder `./jwt-keycloak` to your desired location, i.e: `/etc/kong/plugins/jwt-keycloak`
* Set environmental variables for kong:
    * `LUA_PATH=/etc/?.lua;;`
    * `KONG_PLUGINS=bundled,jwt-keycloak`

See [Dockerfile](./Dockerfile) for more concrete example.

# Usage

## Issuers

Each JWT token has an issuer claim (iss). To be able to validate the JWT's sent to the plugin it needs the public key of each issuer. In the case of keycloak the issuer claim is usually the url to the realm, i.e. `http://localhost:8080/auth/realms/master`.

### Adding issuers

To add an issuer you first need to get the issuer public key. That is as simple as opening a browser and opening the realm url, i.e. `http://localhost:8080/auth/realms/master`.

Then add issuer to the plugin with the corresponding public key:

```bash
curl -X POST http://localhost:8001/jwt-keycloak \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -d '{"iss":"http://localhost:8080/auth/realms/master","public_key":"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnBJCFPf4QJAul+Sn/GOnyojw83Z+nYusbC6XZUbrARbHCX6V5yjNDOQG9UBlSuMWuJZpbdmoQIdnrxHE3lPQKrKSrcQRilzuY294GN84C6EYBouWETksvO2zkzB/Zh3A8mQXbWrmrn/lkYNpA+6FCA8L3qgrojzg5d5j0Upv9qYocVoqowy7VkUHa+6pJscOmRI70AxvslkuX9zi0JFNj2i5Vj2J55OTIM/JhyoqZlFJjd3CEx/cuQzTBiIyyxUH0KTU3gnyoAhiJFPZ2Ovs5XjloMF5rBfXh2r4l937b+rQU/QMGI7IQ7I4t16CTnlSkfNkufZILLpZcECHRN5WjwIDAQAB"}'
```

Note: **Be careful that you do not url-encode the public key**.

### Parameters

| Parameter     | Requied   | Description |
| ------------- | --------- | ----------- |
| iss           | yes       | Name of the issuer as it appears in the access tokens, i.e. `http://localhost:8080/auth/realms/master`. |
| public_key    | yes       | Public key of issuer. |

### Browsing issuers

```bash
curl http://localhost:8001/jwt-keycloak
```

### Changing issuers

```bash
curl -X PATCH http://localhost:8001/jwt-keycloak/eb9c5b16-8a71-4a55-ab4a-33d07b52ad52 \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -d '{"iss":"http://localhost:8080/auth/realms/master1","public_key":"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnBJCFPf4QJAul+Sn/GOnyojw83Z+nYusbC6XZUbrARbHCX6V5yjNDOQG9UBlSuMWuJZpbdmoQIdnrxHE3lPQKrKSrcQRilzuY294GN84C6EYBouWETksvO2zkzB/Zh3A8mQXbWrmrn/lkYNpA+6FCA8L3qgrojzg5d5j0Upv9qYocVoqowy7VkUHa+6pJscOmRI70AxvslkuX9zi0JFNj2i5Vj2J55OTIM/JhyoqZlFJjd3CEx/cuQzTBiIyyxUH0KTU3gnyoAhiJFPZ2Ovs5XjloMF5rBfXh2r4l937b+rQU/QMGI7IQ7I4t16CTnlSkfNkufZILLpZcECHRN5WjwIDAQAB"}'
```

### Deleting issuers

```bash
curl -X DELETE http://localhost:8001/jwt-keycloak/{id}
```

## Enabling on endpoints

The same principle applies to this plugin as the standard jwt plugin that comes with kong. You can enable it on service, routes, apis and globally.

### Service

```bash
curl -X POST http://localhost:8001/services/{service}/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allow_all_iss=true"
```

### Route

```bash
curl -X POST http://localhost:8001/routes/{route_id}/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allow_all_iss=true"
```

### Api

```bash
curl -X POST http://localhost:8001/apis/{api}/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allow_all_iss=true"
```

### Globally

```bash
curl -X POST http://localhost:8001/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allow_all_iss=true"
```

### Parameters

| Parameter                                 | Requied   | Default   | Description |
| ----------------------------------------- | --------- | --------- | ----------- |
| name                                      |           |           | The name of the plugin to use, in this case `keycloak-jwt`. |
| service_id                                |           |           | The id of the Service which this plugin will target. |
| route_id                                  |           |           | The id of the Route which this plugin will target. |
| enabled                                   |           |           | Whether this plugin will be applied. |
| api_id                                    |           |           | The id of the API which this plugin will target. Note: The API Entity is deprecated in favor of Services since CE 0.13.0 and EE 0.32. |
| config.uri_param_names                    | no        | `jwt`     | A list of querystring parameters that Kong will inspect to retrieve JWTs. |
| config.cookie_names                       | no        |           | A list of cookie names that Kong will inspect to retrieve JWTs. |
| config.run_on_preflight                   | no        | `true`    | A boolean value that indicates whether the plugin should run (and try to authenticate) on OPTIONS preflight requests, if set to false then OPTIONS requests will always be allowed. |
| config.maximum_expiration                 | no        | `0`       | An integer limiting the lifetime of the JWT to maximum_expiration seconds in the future. Any JWT that has a longer lifetime will rejected (HTTP 403). If this value is specified, exp must be specified as well in the claims_to_verify property. The default value of 0 represents an indefinite period. Potential clock skew should be considered when configuring this value. |
| config.claims_to_verify                   | no        | `exp`     | A list of registered claims (according to RFC 7519) that Kong can verify as well. Accepted values: exp, nbf |
| config.algorithm                          | no        | `RS256`   | The algorithm used to verify the token's signature. Can be HS256, HS384, HS512, RS256, or ES256. |
| config.allow_all_iss                      | semi      | `false`   | A boolean value that indicates if tokens from all issuers should be allowed to consume this route/service/api. |
| config.allowed_iss                        | semi      |           | A list of allowed issuers for this route/service/api. This parameter is required if `allow_all_iss` is set to false |
| config.roles                              | no        |           | A list of roles of current client the token must have to access the api, i.e. `["uma_protection"]`. The token only has to have one of the listed roles to be authorized. |
| config.realm_roles                        | no        |           | A list of realm roles the token must have to access the api, i.e. `["offline_access"]`. The token only has to have one of the listed roles to be authorized. |
| config.client_roles                       | no        |           | A list of roles of different client the token must have to access the api, i.e. `["account:manage-account"]`. The format for each entry should be `<CLIENT_NAME>:<ROLE_NAME>`. The token only has to have one of the listed roles to be authorized. |
| config.consumer_match                     | no        | `false`   | A boolean value that indicates if the plugin should find a kong consumer with `id`/`custom_id` that equals the `consumer_match_claim` claim in the access token. |
| config.consumer_match_claim               | no        | `azp`     | The claim name in the token that the plugin will try to match the kong `id`/`custom_id` against. |
| config.consumer_match_claim_custom_id     | no        | `false`   | A boolean value that indicates if the plugin should match the `consumer_match_claim` claim against the consumers `id` or `custom_id`. By default it matches the consumer against the `id`. **When matching against `custom_id` consumers are not cached**. |
| config.consumer_match_ignore_not_found    | no        | `false`   | A boolean value that indicates if the request should be let through regardless if the plugin is able to match the request to a kong consumer or not. |

### Example

If you have not already, add the issuer for you tokens:

```bash
curl -X POST http://localhost:8001/jwt-keycloak \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -d '{"iss":"http://localhost:8080/auth/realms/master","public_key":"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnBJCFPf4QJAul+Sn/GOnyojw83Z+nYusbC6XZUbrARbHCX6V5yjNDOQG9UBlSuMWuJZpbdmoQIdnrxHE3lPQKrKSrcQRilzuY294GN84C6EYBouWETksvO2zkzB/Zh3A8mQXbWrmrn/lkYNpA+6FCA8L3qgrojzg5d5j0Upv9qYocVoqowy7VkUHa+6pJscOmRI70AxvslkuX9zi0JFNj2i5Vj2J55OTIM/JhyoqZlFJjd3CEx/cuQzTBiIyyxUH0KTU3gnyoAhiJFPZ2Ovs5XjloMF5rBfXh2r4l937b+rQU/QMGI7IQ7I4t16CTnlSkfNkufZILLpZcECHRN5WjwIDAQAB"}'
```

Create service and add the plugin to it, and lastly create a route:

```bash
curl -X POST http://localhost:8001/services \
    --data "name=mockbin-echo" \
    --data "url=http://mockbin.org/echo"

curl -X POST http://localhost:8001/services/mockbin-echo/plugins \
    --data "name=jwt-keycloak" \
    --data "config.allow_all_iss=true"

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

export TOKEN=$(echo ${TOKENS} | jq -r ".access_token")
curl -H "Authorization: Bearer ${TOKEN}" http://localhost:8000/ \
    --data "working=yeah"
```

# Testing

Requires:
* python
* make
* docker

## Starting all the services

```bash
make keycloak-start
make restart-all
```

## Create test client

Create a client in keycloak admin (master realm):
* Standard flow: off
* Implicit Flow: off
* Direct Access Grants: off
* Service Accounts: on
* Authorization: on

## Running tests

```bash
CLIENT_ID=<YOUR_CLIENT_ID> CLIENT_SECRET=<YOUR_CLIENT_SECRET> make test
```

## Running tests with cassandra

```bash
KONG_DATABASE=cassandra CLIENT_ID=<YOUR_CLIENT_ID> CLIENT_SECRET=<YOUR_CLIENT_SECRET> make test
```