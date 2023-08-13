HTTPBIN_IMAGE:=docker.io/kennethreitz/httpbin
HTTPBIN_CONTAINER_NAME:=kong_test_httpbin
HTTPBIN_PORT:=8093

PGADMIN_IMAGE:=docker.io/dpage/pgadmin4:7.5
PGADMIN_CONTAINER_NAME:=kong_test_pgadmin6
PGADMIN_PORT:=5050
PGADMIN_DEFAULT_EMAIL=pgadmin@subdomain.domain
PGADMIN_DEFAULT_PASSWORD=pgadmin

helpers-start:
	@echo "Starting Helpers ..."
	@docker start ${HTTPBIN_CONTAINER_NAME} || docker run -d \
	--name ${HTTPBIN_CONTAINER_NAME} \
	-p ${HTTPBIN_PORT}:80 \
	${HTTPBIN_IMAGE}
	@docker start ${PGADMIN_CONTAINER_NAME} || docker run -d \
	--name ${PGADMIN_CONTAINER_NAME} \
	--net host \
	-e "PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL}" \
	-e "PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}" \
	-e "PGADMIN_CONFIG_DEBUG=True" \
	-e "PGADMIN_LISTEN_PORT=${PGADMIN_DEFAULT_PASSWORD}" \
	${PGADMIN_IMAGE}

helpers-stop:
	@echo "Stopping Helpers ..."
	- @docker stop ${HTTPBIN_CONTAINER_NAME}
	- @docker rm ${HTTPBIN_CONTAINER_NAME}
	- @docker stop ${PGADMIN_CONTAINER_NAME}
	- @docker rm ${PGADMIN_CONTAINER_NAME}
