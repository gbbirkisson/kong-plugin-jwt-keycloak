local endpoints = require "kong.api.endpoints"
local jwt_keycloak_iss_schema = kong.db.jwt_keycloak_public_keys.schema

return {
    ["/jwt-keycloak"] = {
        schema = jwt_keycloak_iss_schema,
        methods = {
            GET = endpoints.get_collection_endpoint(jwt_keycloak_iss_schema),
            POST = endpoints.post_collection_endpoint(jwt_keycloak_iss_schema),
        },
    },
    ["/jwt-keycloak/:jwt_keycloak_public_keys"] = {
        schema = jwt_keycloak_iss_schema,
        methods = {
            GET = endpoints.get_entity_endpoint(jwt_keycloak_iss_schema),
            PUT = endpoints.put_entity_endpoint(jwt_keycloak_iss_schema),
            PATCH = endpoints.patch_entity_endpoint(jwt_keycloak_iss_schema),
            DELETE = endpoints.delete_entity_endpoint(jwt_keycloak_iss_schema),
        },
    },
}
