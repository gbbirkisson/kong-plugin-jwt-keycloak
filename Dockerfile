## Build plugin
ARG KONG_VERSION
FROM docker.io/kong:${KONG_VERSION} as builder

# Root needed to install dependencies
USER root

# Starting from kong 3.2 they move from alpine to debian .. so conditional install logic is needed
ARG DISTO_ADDONS="zip"
RUN if [ -x "$(command -v apk)" ]; then apk add --no-cache $DISTO_ADDONS; \
    elif [ -x "$(command -v apt-get)" ]; then apt-get update && apt-get install $DISTO_ADDONS; \
    fi
WORKDIR /tmp

COPY ./*.rockspec /tmp
COPY ./LICENSE /tmp/LICENSE
COPY ./src /tmp/src
ARG PLUGIN_VERSION
RUN luarocks make && luarocks pack kong-plugin-jwt-keycloak ${PLUGIN_VERSION}

## Create Image
FROM docker.io/kong:${KONG_VERSION}

ENV KONG_PLUGINS="bundled,jwt-keycloak"

COPY --from=builder /tmp/*.rock /tmp/

# Root needed for installing plugin
USER root

ARG PLUGIN_VERSION
RUN luarocks install /tmp/kong-plugin-jwt-keycloak-${PLUGIN_VERSION}.all.rock
