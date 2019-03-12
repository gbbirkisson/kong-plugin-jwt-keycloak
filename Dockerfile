## Build plugin
ARG VERSION
FROM kong:${VERSION} as builder

RUN apk --no-cache add zip
WORKDIR /tmp

COPY jwt-keycloak /tmp
RUN luarocks make
RUN luarocks pack kong-plugin-jwt-keycloak 1.0-3

## Create Image
FROM kong:${VERSION}

ENV KONG_PLUGINS="bundled,jwt-keycloak"

COPY --from=builder /tmp/* /tmp/
RUN du -h /tmp/kong-plugin-jwt-keycloak-1.0-3.all.rock
RUN luarocks install /tmp/kong-plugin-jwt-keycloak-1.0-3.all.rock && rm /tmp/*