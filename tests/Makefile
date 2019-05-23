UNIT_TEST_IMAGE:=jwt-keycloak-unit-test-image
INTE_TEST_IMAGE:=jwt-keycloak-inte-test-image

_build-unit-test-image:
	@docker build -t ${UNIT_TEST_IMAGE} --build-arg PLUGIN_VERSION=${PLUGIN_VERSION} --build-arg KONG_VERSION=${KONG_VERSION} -f unit_tests/Dockerfile ..

_tests-unit: _build-unit-test-image
	@docker run -it --rm --net=host -v ${PWD}:/jwt-keycloak:ro ${UNIT_TEST_IMAGE}


_build-inte-test-image:
	@docker build -t ${INTE_TEST_IMAGE} -f integration_tests/Dockerfile ..

_tests-integration: _build-inte-test-image
	@docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest discover -s /tests -t /tests -p *.py -v