FROM kong:1.4.0 as builder

ENV LUAROCKS_JWT=kong-plugin-jwt-keycloak
ENV LUAROCKS_JWT_VERSION=1.1.0-1
ENV LUAROCKS_OIDC=kong-oidc
ENV LUAROCKS_OIDC_VERSION=1.1.0-0

RUN apk add --no-cache git zip && \
    git config --global url.https://github.com/.insteadOf git://github.com/ && \
    luarocks install ${LUAROCKS_JWT} ${LUAROCKS_JWT_VERSION} && \
    luarocks pack ${LUAROCKS_JWT} && \
    luarocks install ${LUAROCKS_OIDC} ${LUAROCKS_OIDC_VERSION} && \
    luarocks pack ${LUAROCKS_OIDC}

FROM kong:1.4.0

ENV KONG_PLUGINS="bundled,jwt-keycloak,oidc"
ENV JWT_KEYCLOAK_PRIORITY="900"

COPY --from=builder *.rock /tmp/
RUN luarocks install /tmp/kong-plugin-jwt-keycloak*.rock && \
    luarocks install /tmp/kong-oidc*.rock && \
    rm /tmp/*