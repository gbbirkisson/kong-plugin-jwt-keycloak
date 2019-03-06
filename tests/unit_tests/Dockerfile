FROM ubuntu

# Install openresty and luarocks
RUN apt-get update -y && apt-get install -yqq wget software-properties-common
RUN wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
RUN apt-get update -y && apt-get install -yqq openresty luarocks

# Install dependencies for rocks to be installed
RUN apt-get install -yqq git libssl-dev m4 # for cqueues
RUN git config --global url.https://github.com/.insteadOf git://github.com/

# Install kong and busted
RUN luarocks install kong
RUN luarocks install busted

# Install plugin
COPY ./jwt-keycloak /jwt-keycloak
WORKDIR /jwt-keycloak
RUN luarocks make
RUN luarocks pack jwt-keycloak 1.0-2
RUN luarocks install jwt-keycloak-1.0-2.all.rock

# Add custom busted binary
COPY tests/unit_tests/busted_bin /usr/bin/busted
COPY tests/unit_tests/busted_bin /usr/local/bin/busted

# Copy and run tests
COPY tests/unit_tests/tests /tests
WORKDIR /tests
CMD ["busted", "."]