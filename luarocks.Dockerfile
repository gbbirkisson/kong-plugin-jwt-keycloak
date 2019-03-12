FROM kong:1.0

RUN luarocks install kong-plugin-jwt-keycloak
ENV KONG_PLUGINS="bundled,jwt-keycloak"