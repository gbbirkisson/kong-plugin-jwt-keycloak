include makefiles/*.mk

REPOSITORY?=gbbirkisson
IMAGE?=kong-plugin-jwt-keycloak
VERSION?=1.0
FULL_IMAGE_NAME:=${REPOSITORY}/${IMAGE}:${VERSION}

TEST_VERSIONS?=1.0.0 1.0.1 1.0.3 1.1rc1

build:
	docker build -t ${FULL_IMAGE_NAME} --build-arg VERSION=${VERSION} .

run: build
	docker run -it --rm ${FULL_IMAGE_NAME} kong start --vv

exec: build
	docker run -it --rm ${FULL_IMAGE_NAME} ash

push: build test
	docker push ${FULL_IMAGE_NAME}

### Testing ###

start: kong-db-start kong-start
restart: kong-stop kong-start
restart-all: stop start
stop: kong-stop kong-db-stop

test: restart-all sleep
	@echo ======================================================================
	@echo "Testing kong version ${VERSION} with ${KONG_DATABASE}"
	@echo

	@cd tests && $(MAKE) --no-print-directory tests-integration

	@echo ======================================================================
	@echo "Testing kong version ${VERSION} with ${KONG_DATABASE} was successful"
	@echo

test-all:
	@echo ======================================================================
	@echo "Running unit tests"
	@cd tests && $(MAKE) --no-print-directory tests-unit
	@echo "Unit tests passed"
	@echo ======================================================================
	
	@echo "Starting integration tests for multiple versions"
	@set -e; for t in  $(TEST_VERSIONS); do \
    $(MAKE) --no-print-directory test VERSION=$$t KONG_DATABASE=postgres ; \
		$(MAKE) --no-print-directory test VERSION=$$t KONG_DATABASE=cassandra ; \
    done
	@echo "All test successful"

sleep:
	sleep 5