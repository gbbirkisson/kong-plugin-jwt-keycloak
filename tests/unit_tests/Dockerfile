FROM alpine:3.12

ENV LUA_VERSION=5.1.5
ENV LUAROCKS_VERSION=3.4.0
ENV OPENRESTY_PUB_KEY="http://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub"

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    openssl \
    curl \
    unzip \
    gcc \
    git \
    libc-dev \
    libressl-dev \
    yaml-dev \
    make \
    m4 \
    zlib-dev \
    bsd-compat-headers

# Install openresty
RUN wget -O "/etc/apk/keys/$(basename ${OPENRESTY_PUB_KEY})" ${OPENRESTY_PUB_KEY} \
    && echo "http://openresty.org/package/alpine/v3.12/main" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache openresty-resty 

# Install Lua
RUN wget -c https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz -O - | tar -xzf - \
    && cd lua-${LUA_VERSION} \
    && make -j"$(nproc)" posix \
    && make install \
    && cd .. \
    && rm -rf lua-${LUA_VERSION}

# Install luarocks
RUN wget -c https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -O - | tar -xzf - \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure --with-lua=/usr/local \
    && make build \
    && make install \
    && cd .. \
    && rm -rf luarocks-${LUAROCKS_VERSION}

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
RUN luarocks make 

# Add custom busted binary
COPY tests/unit_tests/busted_bin /usr/bin/busted
COPY tests/unit_tests/busted_bin /usr/local/bin/busted

# Copy and run tests
COPY tests/unit_tests/tests /tests
WORKDIR /tests
CMD ["busted", "."]
