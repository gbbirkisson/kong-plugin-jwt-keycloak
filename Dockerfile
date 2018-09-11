ARG VERSION
FROM kong:${VERSION}

ENV LUA_PATH=/etc/?.lua;; \
    KONG_PLUGINS=bundled,jwt-keycloak

COPY jwt-keycloak /etc/kong/plugins/jwt-keycloak