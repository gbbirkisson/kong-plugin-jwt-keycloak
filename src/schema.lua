local typedefs = require "kong.db.schema.typedefs"

return {
  name = "jwt-keycloak-endpoint",
  fields = {
    { consumer = typedefs.no_consumer },
    { config = {
        type = "record",
        fields = {
          { algorithm = { type = "string", default = "RS256" }, },
          { allowed_iss = { type = "set", elements = { type = "string" }, required = true }, },
          { anonymous = { type = "string", uuid = true, legacy = true }, },
          { claims_to_verify = { type = "set", elements = { type = "string", one_of = { "exp", "nbf" }, }, default = { "exp" } }, },
          { client_roles = { type = "set", elements = { type = "string" }, default = nil }, },
          { consumer_match = { type = "boolean", default = false }, },
          { consumer_match_claim = { type = "string", default = "azp" }, },
          { consumer_match_claim_custom_id = { type = "boolean", default = false }, },
          { consumer_match_ignore_not_found = { type = "boolean", default = false }, },
          { cookie_names = { type = "set", elements = { type = "string" }, default = {} }, },
          { hide_credentials = { type = "boolean", required = true, default = true }, },
          { iss_key_grace_period = { type = "number", default = 10, between = { 1, 60 }, }, },
          { maximum_expiration = { type = "number", default = 0, between = { 0, 31536000 }, }, },
          { realm_roles = { type = "set", elements = { type = "string" }, default = nil }, },
          { roles = { type = "set", elements = { type = "string" }, default = nil }, },
          { run_on_preflight = { type = "boolean", default = true }, },
          { scope = { type = "set", elements = { type = "string" }, default = nil }, },
          { scope_claim = { type = "string", default = "scope" }, },
          { uri_param_names = { type = "set", elements = { type = "string" }, default = { "jwt" }, }, },
          { well_known_template = { type = "string", default = "%s/.well-known/openid-configuration" }, },
        },
      },
    },
  },
}
