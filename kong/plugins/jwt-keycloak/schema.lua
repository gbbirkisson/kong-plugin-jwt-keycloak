local typedefs = require "kong.db.schema.typedefs"

return {
  name = "jwt-keycloak-endpoint",
  fields = {
    { consumer = typedefs.no_consumer },
    { config = {
        type = "record",
        fields = {
          { uri_param_names = { type = "set", elements = { type = "string" }, default = { "jwt" }, }, },
          { cookie_names = { type = "set", elements = { type = "string" }, default = {} }, },
          { claims_to_verify = { type = "set", elements = { type = "string", one_of = { "exp", "nbf" }, }, default = { "exp" } }, },
          { anonymous = { type = "string", uuid = true, legacy = true }, },
          { run_on_preflight = { type = "boolean", default = true }, },
          { maximum_expiration = { type = "number", default = 0, between = { 0, 31536000 }, }, },
          { algorithm = { type = "string", default = "RS256" }, },

          { allowed_iss = { type = "set", elements = { type = "string" }, required = true }, },
          { iss_key_grace_period = { type = "number", default = 10, between = { 1, 60 }, }, },
          { well_known_template = { type = "string", default = "%s/.well-known/openid-configuration" }, },
          
          { scope = { type = "set", elements = { type = "string" }, default = nil }, },
          { roles = { type = "set", elements = { type = "string" }, default = nil }, },
          { realm_roles = { type = "set", elements = { type = "string" }, default = nil }, },
          { client_roles = { type = "set", elements = { type = "string" }, default = nil }, },

          { consumer_match = { type = "boolean", default = false }, },
          { consumer_match_claim = { type = "string", default = "azp" }, },
          { consumer_match_claim_custom_id = { type = "boolean", default = false }, },
          { consumer_match_ignore_not_found = { type = "boolean", default = false }, },
        },
      },
    },
  },
}