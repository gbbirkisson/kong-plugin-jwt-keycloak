KONG_CONTAINER_NAME:=kong
KONG_PORT:=8000
KONG_ADMIN_PORT:=8001

KONG_DB_CONTAINER_NAME:=kongdb
KONG_DB_PORT:=5432
KONG_DB_USER:=kong
KONG_DB_PASS:=kong
KONG_DB_NAME:=kong
KONG_DATABASE?=postgres

POSTGRES_IMAGE:=postgres:11.2-alpine
CASSANDRA_IMAGE:=cassandra:3.11

wait-for-log:
	@while ! docker logs ${CONTAINER} | grep -q "${PATTERN}"; do sleep 5; done

kong-db-create:
	@$(MAKE) --no-print-directory kong-db-create-${KONG_DATABASE}

kong-db-create-postgres:
	@echo "Creating Kong DB"
	- @docker run --rm -d \
		--name ${KONG_DB_CONTAINER_NAME} \
		--net=host \
		 -e POSTGRES_USER=${KONG_DB_USER} \
		 -e POSTGRES_DB=${KONG_DB_PASS} \
		 -e POSTGRES_PASSWORD=${KONG_DB_NAME} \
		 ${POSTGRES_IMAGE}
	@$(MAKE) --no-print-directory CONTAINER=${KONG_DB_CONTAINER_NAME} PATTERN="database system is ready to accept connections" wait-for-log

kong-db-create-cassandra:
	@echo "Creating Kong DB"
	- @docker run --rm -d \
		--name ${KONG_DB_CONTAINER_NAME} \
		--net=host \
		 ${CASSANDRA_IMAGE}
	@$(MAKE) --no-print-directory CONTAINER=${KONG_DB_CONTAINER_NAME} PATTERN="Starting listening for CQL clients" wait-for-log

kong-db-migrate: build
	@echo "Migrating Kong DB"
	@docker run -it --rm \
		--name ${KONG_CONTAINER_NAME} \
		--net=host \
		-e "KONG_DATABASE=${KONG_DATABASE}" \
		-e "KONG_CASSANDRA_CONTACT_POINTS=localhost" \
		-e "KONG_PG_HOST=localhost" \
		-e "KONG_PG_USER=${KONG_DB_USER}" \
		-e "KONG_PG_PASSWORD=${KONG_DB_PASS}" \
		-e "KONG_PG_DATABASE=${KONG_DB_NAME}" \
		${FULL_IMAGE_NAME} kong migrations bootstrap --vv

kong-db-start: kong-db-create kong-db-migrate

kong-db-stop:
	@echo "Removing Kong DB..."
	- @docker stop ${KONG_DB_CONTAINER_NAME}

kong-start: build
	@echo "Creating kong..."
	@docker run -d --rm \
		--name ${KONG_CONTAINER_NAME} \
		--net=host \
        -e "KONG_LOG_LEVEL=debug" \
        -e "KONG_PROXY_ACCESS_LOG=/proxy_access.log" \
        -e "KONG_ADMIN_ACCESS_LOG=/admin_access.log" \
        -e "KONG_PROXY_ERROR_LOG=/proxy_error.log" \
        -e "KONG_ADMIN_ERROR_LOG=/admin_error.log" \
		-e "KONG_DATABASE=${KONG_DATABASE}" \
		-e "KONG_CASSANDRA_CONTACT_POINTS=localhost" \
		-e "KONG_PG_HOST=localhost" \
		-e "KONG_PG_USER=${KONG_DB_USER}" \
		-e "KONG_PG_PASSWORD=${KONG_DB_PASS}" \
		-e "KONG_PG_DATABASE=${KONG_DB_NAME}" \
		-e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
        ${FULL_IMAGE_NAME} kong start --vv

kong-stop:
	@echo "Removing Kong..."
	- @docker stop ${KONG_CONTAINER_NAME}

kong-log:
	- @docker logs -f ${KONG_CONTAINER_NAME}

kong-err-proxy:
	- @docker exec -it ${KONG_CONTAINER_NAME} tail -f -n 100 /proxy_error.log

kong-err-admin:
	- @docker exec -it ${KONG_CONTAINER_NAME} tail -f -n 100 /admin_error.log

kong-restart: kong-stop kong-db-stop kong-create
	- @docker logs ${KONG_CONTAINER_NAME}