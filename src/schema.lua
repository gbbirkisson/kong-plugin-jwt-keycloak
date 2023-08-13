local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "jwt-keycloak"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { uri_param_names = {
              -- description = "A list of querystring parameters that Kong will inspect to retrieve JWTs.",
              type = "set",
              elements = { type = "string" },
              default = { "jwt" },
          }, },
          { cookie_names = {
              -- description = "A list of cookie names that Kong will inspect to retrieve JWTs.",
              type = "set",
              elements = { type = "string" },
              default = {}
          }, },
          { claims_to_verify = {
              -- description = "A list of registered claims (according to RFC 7519) that Kong can verify as well. Accepted values: one of exp or nbf.",
              type = "set",
              elements = {
                type = "string",
                one_of = { "exp", "nbf" },
              },
              default = { "exp" },
           }, },
          { anonymous = { 
              -- description = "An optional string (consumer UUID or username) value to use as an �anonymous� consumer if authentication fails.",
              type = "string"
          }, },
          { run_on_preflight = { 
              -- description = "A boolean value that indicates whether the plugin should run (and try to authenticate) on OPTIONS preflight requests. If set to false, then OPTIONS requests will always be allowed.",
              type = "boolean",
              required = true,
              default = true
          }, },
          { maximum_expiration = {
            -- description = "A value between 0 and 31536000 (365 days) limiting the lifetime of the JWT to maximum_expiration seconds in the future.",
            type = "number",
            default = 0,
            between = { 0, 31536000 },
          }, },
          { header_names = {
            -- description = "A list of HTTP header names that Kong will inspect to retrieve JWTs.",
            type = "set",
            elements = { type = "string" },
            default = { "authorization" },
          }, },

          { algorithm = {  type = "string", default = "RS256" }, },
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
          { cafile = { type = "string" }, },
        },
      },
    },
  },
  entity_checks = {
    { conditional = {
        if_field = "config.maximum_expiration",
        if_match = { gt = 0 },
        then_field = "config.claims_to_verify",
        then_match = { contains = "exp" },
    }, },
  },
}

return schema
