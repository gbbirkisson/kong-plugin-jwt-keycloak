include makefiles/*.mk

REPOSITORY?=gbbirkisson
IMAGE?=kong-plugin-jwt-keycloak
VERSION?=0.14.1
FULL_IMAGE_NAME:=${REPOSITORY}/${IMAGE}:${VERSION}

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
	python -m unittest discover -s ./tests -t ./tests -p *.py

sleep:
	sleep 5