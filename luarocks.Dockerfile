FROM kong:2.1.4 as builder

ENV LUAROCKS_MODULE=kong-plugin-jwt-keycloak

USER root

RUN apk add --no-cache git zip && \
    git config --global url.https://github.com/.insteadOf git://github.com/ && \
    luarocks install ${LUAROCKS_MODULE} && \
    luarocks pack ${LUAROCKS_MODULE}

FROM kong:2.1.4

ENV KONG_PLUGINS="bundled,jwt-keycloak"

USER root

COPY --from=builder kong-plugin-jwt-keycloak* /tmp/
RUN luarocks install /tmp/kong-plugin-jwt-keycloak* && \
    rm /tmp/*
