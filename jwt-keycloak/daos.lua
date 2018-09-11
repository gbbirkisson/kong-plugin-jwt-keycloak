local SCHEMA = {
  primary_key = {"id"},
  table = "jwt_keycloak_public_keys",
  cache_key = { "iss" },
  fields = {
    id = {type = "id", dao_insert_value = true},
    created_at = {type = "timestamp", immutable = true, dao_insert_value = true},
    iss = {type = "string", required = true, unique = true },
    public_key = {type = "string", required = true, trim_whitespace = false}
  },
}

return {jwt_keycloak_public_keys = SCHEMA}