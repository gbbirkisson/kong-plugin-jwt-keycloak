# Nokia-OICD demo

This is to demonstrate how to use the Nokia-OICD plugin with this one.

## Dockerfile

See the [Dockerfile](./kong/Dockerfile) to see how to install and configure the plugins together.

## Running the demo

1. Running services
   1. Run `docker-compose build` to create Kong image.
   2. Run `docker-compose up -d db keycloak` to start postgres, keycloak and echo server.
   3. Run `docker-compose up kong-migrate` to run migrations.
   4. Run `docker-compose up kong` to start kong.
2. Configure Keycloak
   1. Open up the [keycloak admin](http://localhost:8080/auth/)
   2. Create client with:
      1. `Access type` set as `confidential`
      2. `Valid Redirect URIs` set as `*`
   3. Note down client_id and client_secret for next step
3. Configure Kong
   1. Enable OICD plugin on Kong:
        ```
        curl -X POST localhost:8001/plugins \
            -F 'name=oidc' \
            -F 'config.realm=master' \
            -F 'config.client_id=<YOUR_CLIENT_ID>' \
            -F 'config.client_secret=<YOUR_CLIENT_SECRET>' \
            -F 'config.discovery=http://localhost:8080/auth/realms/master/.well-known/openid-configuration'
        ```
   2. Create route and apply the JWT plugin:
        ```bash
        curl -X POST http://localhost:8001/services \
            -F "name=echo" \
            -F "url=http://localhost:9000"

        curl -X POST http://localhost:8001/services/echo/routes \
            -F "paths=/"

        curl -X POST http://localhost:8001/services/echo/plugins \
            -F "name=jwt-keycloak" \
            -F "config.allowed_iss=http://localhost:8080/auth/realms/master" \
            -F "config.cookie_names=session" # THIS DOESNT WORK :(
        ```
4. Call service with browser: [http://localhost:8000/](http://localhost:8000/)