KEYCLOAK_IMAGE:=jboss/keycloak:6.0.1
KEYCLOAK_CONTAINER_NAME:=kc_local
KEYCLOAK_PORT:=8080
KEYCLOAK_ADMIN_USER:=admin
KEYCLOAK_ADMIN_PASS:=admin

keycloak-start:
	@echo "Running Keycloak..."
	-- @docker run -d \
	--name ${KEYCLOAK_CONTAINER_NAME} \
	-p ${KEYCLOAK_PORT}:8080 \
	-e KEYCLOAK_USER=${KEYCLOAK_ADMIN_USER} \
	-e KEYCLOAK_PASSWORD=${KEYCLOAK_ADMIN_PASS} \
	${KEYCLOAK_IMAGE}

keycloak-stop:
	@echo "Stopping Keycloak"
	- @docker stop ${KEYCLOAK_CONTAINER_NAME}

keycloak-rm: keycloak-stop
	@echo "Removing Keycloak"
	- @docker rm ${KEYCLOAK_CONTAINER_NAME}