local Errors = require "kong.dao.errors"

local function check_positive(v)
  if v < 0 then
    return false, "should be 0 or greater"
  end

  return true
end

return {
  no_consumer = true,
  fields = {
    uri_param_names = {type = "array", default = {"jwt"}},
    cookie_names = {type = "array", default = {}},
    run_on_preflight = {type = "boolean", default = true},
    maximum_expiration = {type = "number", default = 0, func = check_positive},
    claims_to_verify = {type = "array", enum = {"exp", "nbf"}, default = {"exp"}},
    algorithm = {type = "string", default = "RS256"},
    allow_all_iss = {type = "boolean", default = false},
    allowed_iss = {type = "array", default = nil},
    roles = {type = "array", default = nil},
    realm_roles = {type = "array", default = nil},
    client_roles = {type = "array", default = nil},
    consumer_match = {type = "boolean", default=false},
    consumer_match_claim = {type = "string", default="azp"},
    consumer_match_claim_custom_id = {type = "boolean", default = false},
    consumer_match_ignore_not_found = {type = "boolean", default=false}
  },
  self_check = function(schema, plugin_t, dao, is_update)
    if not plugin_t.allow_all_iss and (not plugin_t.allowed_iss or not next(plugin_t.allowed_iss)) then
      return false, Errors.schema "You must set 'allowed_iss' if 'allow_all_iss' is set to false"
    end
    return true
  end
}
