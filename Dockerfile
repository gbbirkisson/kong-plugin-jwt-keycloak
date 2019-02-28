## Build plugin
ARG VERSION
FROM kong:${VERSION} as builder

RUN apk --no-cache add zip
WORKDIR /tmp

COPY jwt-keycloak /tmp
RUN luarocks make
RUN luarocks pack jwt-keycloak 1.0-2

## Create Image
FROM kong:${VERSION}

ENV KONG_PLUGINS="bundled,jwt-keycloak"

COPY --from=builder /tmp/* /tmp/
RUN luarocks install /tmp/jwt-keycloak-1.0-2.all.rock && rm /tmp/*