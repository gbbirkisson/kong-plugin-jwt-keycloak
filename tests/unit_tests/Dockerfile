FROM ubuntu:18.04

# Install openresty and luarocks
RUN apt-get update -y && apt-get install -yqq wget software-properties-common
RUN wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
RUN apt-get update -y && apt-get install -yqq openresty luarocks

# Install dependencies for rocks to be installed
RUN apt-get install -yqq git libssl-dev m4 libyaml-dev
RUN git config --global url.https://github.com/.insteadOf git://github.com/

# Install kong and busted
RUN luarocks install busted

ARG KONG_VERSION
RUN luarocks install kong ${KONG_VERSION}-0

# Install plugin
COPY ./*.rockspec /tmp
COPY ./LICENSE /tmp/LICENSE
COPY ./src /tmp/src
WORKDIR /tmp
ARG PLUGIN_VERSION
RUN luarocks make && luarocks pack kong-plugin-jwt-keycloak ${PLUGIN_VERSION}

# Add custom busted binary
COPY tests/unit_tests/busted_bin /usr/bin/busted
COPY tests/unit_tests/busted_bin /usr/local/bin/busted

# Copy and run tests
COPY tests/unit_tests/tests /tests
WORKDIR /tests
CMD ["busted", "."]