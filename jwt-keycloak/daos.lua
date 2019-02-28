local typedefs = require "kong.db.schema.typedefs"

return {
    jwt_keycloak_public_keys = {
        name = "jwt_keycloak_public_keys",
        primary_key = { "id" },
        cache_key = { "iss" },
        endpoint_key = "id",
        fields = {
            { id = typedefs.uuid },
            { created_at = typedefs.auto_timestamp_s },
            { iss = { type = "string", required = true, unique = true }, },
            { public_key = { type = "string", required = true, unique = true }, },
        },
    },
}