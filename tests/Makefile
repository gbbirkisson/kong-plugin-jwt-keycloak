TEST_IMAGE:=jwt-keycloak-test-image

build-testimage:
	docker build -t ${TEST_IMAGE} -f unit_tests/Dockerfile ..

tests-unit: build-testimage
	docker run -it --rm --net=host -v ${PWD}:/jwt-keycloak:ro ${TEST_IMAGE}

tests-integration:
	@python -m unittest discover -s ./integration_tests -t ./integration_tests -p *.py -v