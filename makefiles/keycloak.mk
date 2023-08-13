KEYCLOAK_IMAGE:=quay.io/keycloak/keycloak:15.0.2
# KEYCLOAK_IMAGE:=quay.io/keycloak/keycloak:18.0.2 #--> Look deeper. There is a problem wir keycloak key rotation test results
KEYCLOAK_CONTAINER_NAME:=kong_test_keycloack
KEYCLOAK_PORT:=8080
KEYCLOAK_ADMIN_USER:=admin
KEYCLOAK_ADMIN_PASS:=admin

keycloak-start:
	@echo "Running Keycloak..."
	-- @docker start ${KEYCLOAK_CONTAINER_NAME} || docker run -d \
	--name ${KEYCLOAK_CONTAINER_NAME} \
	-p ${KEYCLOAK_PORT}:8080 \
	-e KEYCLOAK_USER=${KEYCLOAK_ADMIN_USER} \
	-e KEYCLOAK_PASSWORD=${KEYCLOAK_ADMIN_PASS} \
	-e KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN_USER} \
	-e KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASS} \
	${KEYCLOAK_IMAGE}
    # start-dev --http-relative-path /auth # needed starting from keycloak 18
	@bash -c 'while ! timeout 1 bash -c "echo > /dev/tcp/localhost/8080"; do sleep 1; done'

keycloak-stop:
	@echo "Stopping Keycloak"
	- @docker stop ${KEYCLOAK_CONTAINER_NAME}

keycloak-rm: keycloak-stop
	@echo "Removing Keycloak"
	- @docker rm ${KEYCLOAK_CONTAINER_NAME}

keycloak-restart: keycloak-rm keycloak-start
	@echo "Restarted Keycloak..."

keycloak-logs:
	- @docker logs --follow ${KEYCLOAK_CONTAINER_NAME}
