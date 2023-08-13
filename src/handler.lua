local constants = require "kong.constants"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local kong_meta = require "kong.meta"

local socket = require "socket"
local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")

local validate_issuer = require("kong.plugins.jwt-keycloak.validators.issuers").validate_issuer
local validate_scope = require("kong.plugins.jwt-keycloak.validators.scope").validate_scope
local validate_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_roles
local validate_realm_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_realm_roles
local validate_client_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_client_roles

local re_gmatch = ngx.re.gmatch

local priority_env_var = "JWT_KEYCLOAK_PRIORITY"
local priority
if os.getenv(priority_env_var) then
    priority = tonumber(os.getenv(priority_env_var))
else
    priority = 1005
end
kong.log.debug('JWT_KEYCLOAK_PRIORITY: ' .. priority)

local JwtKeycloakHandler = {
  VERSION = kong_meta.version,
  PRIORITY = priority,
}

-------------------------------------------------------------------------------
-- custom helper function of the extended plugin "jwt-keycloak"
-- --> this is not contained in the official "jwt" pluging
-------------------------------------------------------------------------------
local function custom_helper_table_to_string(tbl)
  local result = ""
  for k, v in pairs(tbl) do
      -- Check the key type (ignore any numerical keys - assume its an array)
      if type(k) == "string" then
          result = result.."[\""..k.."\"]".."="
      end

      -- Check the value type
      if type(v) == "table" then
          result = result..custom_helper_table_to_string(v)
      elseif type(v) == "boolean" then
          result = result..tostring(v)
      else
          result = result.."\""..v.."\""
      end
      result = result..","
  end
  -- Remove leading commas from the result
  if result ~= "" then
      result = result:sub(1, result:len()-1)
  end
  return result
end

-------------------------------------------------------------------------------
-- custom helper function of the extended plugin "jwt-keycloak"
-- --> this is not contained in the official "jwt" pluging
-------------------------------------------------------------------------------
local function custom_helper_issuer_get_keys(well_known_endpoint, cafile)
  kong.log.debug('Getting public keys from token issuer')
  local keys, err = keycloak_keys.get_issuer_keys(well_known_endpoint, cafile)
  if err then
      return nil, err
  end

  local decoded_keys = {}
  for i, key in ipairs(keys) do
      decoded_keys[i] = jwt_decoder:base64_decode(key)
  end

  kong.log.debug('Number of keys retrieved: ' .. table.getn(decoded_keys))
  return {
      keys = decoded_keys,
      updated_at = socket.gettime(),
  }
end

-------------------------------------------------------------------------------
-- custom keycloak specific extension for the plugin "jwt-keycloak"
-- --> This is for one of the main benefits when using this plugin
--
-- This validates the token against the token issuer is the token is really
-- issued by this instance. The URL from inside the token from the "iss"
-- information is taken to connect with the token issuer instance.
-------------------------------------------------------------------------------
local function custom_validate_token_signature(conf, jwt, second_call)
  local issuer_cache_key = 'issuer_keys_' .. jwt.claims.iss

  local well_known_endpoint = keycloak_keys.get_wellknown_endpoint(conf.well_known_template, jwt.claims.iss)
  -- Retrieve public keys
  local public_keys, err = kong.cache:get(issuer_cache_key, nil, custom_helper_issuer_get_keys, well_known_endpoint, conf.cafile)

  if not public_keys then
      if err then
          kong.log.err(err)
      end
      return kong.response.exit(403, { message = "Unable to get public key for issuer" })
  end

  -- Verify signatures
  for _, k in ipairs(public_keys.keys) do
      if jwt:verify_signature(k) then
          kong.log.debug('JWT signature verified')
          return nil
      end
  end

  -- We could not validate signature, try to get a new keyset?
  local since_last_update = socket.gettime() - public_keys.updated_at
  if not second_call and since_last_update > conf.iss_key_grace_period then
      kong.log.debug('Could not validate signature. Keys updated last ' .. since_last_update .. ' seconds ago')
      -- can it be that the signature key of the issuer has changed ... ?
      -- invalidate the old keys in kong cache and do a current lookup to the signature keys
      -- of the token issuer
      kong.cache:invalidate_local(issuer_cache_key)
      return custom_validate_token_signature(conf, jwt, true)
  end

  return kong.response.exit(401, { message = "Invalid token signature" })
end

-------------------------------------------------------------------------------
-- custom keycloak specific extension for the plugin "jwt-keycloak"
-- --> This is for one of the main benefits when using this plugin
--
-- The extension of this plugin uses kong cache to store things...
-- so it is needed also to handle invalidation properly.
-- See:
-- https://github.com/gbbirkisson/kong-plugin-jwt-keycloak/issues/28
-- https://docs.konghq.com/gateway-oss/2.2.x/plugin-development/entities-cache/#manual-cache-invalidation
-------------------------------------------------------------------------------
local function get_consumer_custom_id_cache_key(custom_id)
  return "custom_id_key_" .. custom_id
end

local function invalidate_customer(data)
  local customer = data.entity
  if data.operation == "update" then
    customer = data.old_entity
  end

  local key = get_consumer_custom_id_cache_key(customer.custom_id)
  kong.log.debug("invalidating customer " .. key)
  kong.cache:invalidate(key)
end

-- register at startup for events to be able to receive invalidate request needs
function JwtKeycloakHandler:init_worker()
  kong.worker_events.register(invalidate_customer, "crud", "consumers")
end


-------------------------------------------------------------------------------
-- Starting from here the "official" code of the community kong OSS version
-- plugin "jwt" is forked and in some places then extended with the special
-- logic from this plugin.
--
-- We use this ordering by intention that way .. if a new version of the
-- "jwt" plugin from kong is released .. these changes can me merged also
-- to this plugin here .... make the maintenance as easy as possible ...
--
-- This code is in sync with kong verion "3.3.0" jwt plugin as a baseline
-------------------------------------------------------------------------------


--- Retrieve a JWT in a request.
-- Checks for the JWT in URI parameters, then in cookies, and finally
-- in the configured header_names (defaults to `[Authorization]`).
-- @param conf Plugin configuration
-- @return token JWT token contained in request (can be a table) or nil
-- @return err
local function retrieve_tokens(conf)
  local token_set = {}
  local args = kong.request.get_query()
  for _, v in ipairs(conf.uri_param_names) do
    local token = args[v] -- can be a table
    if token then
      if type(token) == "table" then
        for _, t in ipairs(token) do
          if t ~= "" then
            token_set[t] = true
          end
        end

      elseif token ~= "" then
        token_set[token] = true
      end
    end
  end

  local var = ngx.var
  for _, v in ipairs(conf.cookie_names) do
    local cookie = var["cookie_" .. v]
    if cookie and cookie ~= "" then
      token_set[cookie] = true
    end
  end

  local request_headers = kong.request.get_headers()
  for _, v in ipairs(conf.header_names) do
    local token_header = request_headers[v]
    if token_header then
      if type(token_header) == "table" then
        token_header = token_header[1]
      end
      local iterator, iter_err = re_gmatch(token_header, "\\s*[Bb]earer\\s+(.+)")
      if not iterator then
        kong.log.err(iter_err)
        break
      end

      local m, err = iterator()
      if err then
        kong.log.err(err)
        break
      end

      if m and #m > 0 then
        if m[1] ~= "" then
          token_set[m[1]] = true
        end
      end
    end
  end

  local tokens_n = 0
  local tokens = {}
  for token, _ in pairs(token_set) do
    tokens_n = tokens_n + 1
    tokens[tokens_n] = token
  end

  if tokens_n == 0 then
    return nil
  end

  if tokens_n == 1 then
    return tokens[1]
  end

  return tokens
end


local function set_consumer(consumer, credential, token)
  kong.client.authenticate(consumer, credential)

  local set_header = kong.service.request.set_header
  local clear_header = kong.service.request.clear_header

  if consumer and consumer.id then
    set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
  else
    clear_header(constants.HEADERS.CONSUMER_ID)
  end

  if consumer and consumer.custom_id then
    kong.log.debug("found consumer " .. consumer.custom_id)
    set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
  else
    clear_header(constants.HEADERS.CONSUMER_CUSTOM_ID)
  end

  if consumer and consumer.username then
    set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
  else
    clear_header(constants.HEADERS.CONSUMER_USERNAME)
  end

  if credential and credential.key then
    set_header(constants.HEADERS.CREDENTIAL_IDENTIFIER, credential.key)
  else
    clear_header(constants.HEADERS.CREDENTIAL_IDENTIFIER)
  end

  if credential then
    clear_header(constants.HEADERS.ANONYMOUS)
  else
    set_header(constants.HEADERS.ANONYMOUS, true)
  end

  ngx.ctx.authenticated_jwt_token = token  -- backward compatibilty only
  kong.ctx.shared.authenticated_jwt_token = token -- TODO: wrap in a PDK function?
end


-------------------------------------------------------------------------------
-- custom keycloak specific extension for the plugin "jwt-keycloak"
-- --> This is for one of the main benefits when using this plugin
--
-- The extension of this plugin provides the possibility to enforce "matching"
-- of consumer id from the token against the kong user object in the config
-- in a very configurable way.
-------------------------------------------------------------------------------
local function custom_load_consumer_by_custom_id(custom_id)
  local result, err = kong.db.consumers:select_by_custom_id(custom_id)
  if not result then
      return nil, err
  end
  return result
end

local function custom_match_consumer(conf, jwt)
  local consumer, err
  local consumer_id = jwt.claims[conf.consumer_match_claim]

  if conf.consumer_match_claim_custom_id then
      local consumer_cache_key = get_consumer_custom_id_cache_key(consumer_id)
      consumer, err = kong.cache:get(consumer_cache_key, nil, custom_load_consumer_by_custom_id, consumer_id, true)
  else
      local consumer_cache_key = kong.db.consumers:cache_key(consumer_id)
      consumer, err = kong.cache:get(consumer_cache_key, nil, kong.client.load_consumer, consumer_id, true)
  end

  if err then
      kong.log.err(err)
  end

  if not consumer and not conf.consumer_match_ignore_not_found then
      kong.log.debug("Unable to find consumer " .. consumer_id .." for token")
      return false, { status = 401, message = "Unable to find consumer " .. consumer_id .." for token" }
  end

  if consumer then
      set_consumer(consumer, nil, nil)
  end

  return true
end

-------------------------------------------------------------------------------
-- Now again module names which also exist in original "jwt" kong OSS plugin
-------------------------------------------------------------------------------

local function do_authentication(conf)
  local token, err = retrieve_tokens(conf)
  if err then
    kong.log.err(err)
    return kong.response.exit(500, { message = "An unexpected error occurred" })
  end

  local token_type = type(token)
  if token_type ~= "string" then
    if token_type == "nil" then
      return false, { status = 401, message = "Unauthorized" }
    elseif token_type == "table" then
      return false, { status = 401, message = "Multiple tokens provided" }
    else
      return false, { status = 401, message = "Unrecognizable token" }
    end
  end

  -- Decode token to find out who the consumer is
  local jwt, err = jwt_decoder:new(token)
  if err then
    return false, { status = 401, message = "Bad token; " .. tostring(err) }
  end

  local claims = jwt.claims
  local header = jwt.header

  -- Verify that the issuer is allowed
  if not validate_issuer(conf.allowed_iss, jwt.claims) then
    return false, { status = 401, message = "Token issuer not allowed" }
  end

  local algorithm = conf.algorithm or "HS256"

  -- Verify "alg"
  if jwt.header.alg ~= algorithm then
    return false, { status = 403, message = "Invalid algorithm" }
  end

  -- Now verify the JWT signature
  err = custom_validate_token_signature(conf, jwt)
  if err ~= nil then
    return false, err
  end

  -- Verify the JWT registered claims
  local ok_claims, errors = jwt:verify_registered_claims(conf.claims_to_verify)
  if not ok_claims then
    return false, { status = 401, message = "Token claims invalid: " .. custom_helper_table_to_string(errors) }
  end

  -- Verify maximum expiration

  -- Verify the JWT registered claims
  if conf.maximum_expiration ~= nil and conf.maximum_expiration > 0 then
    local ok, errors = jwt:check_maximum_expiration(conf.maximum_expiration)
    if not ok then
      return false, { status = 403, message = "Token claims invalid: " .. custom_helper_table_to_string(errors) }
    end
  end

  -- Match consumer
  if conf.consumer_match then
    local ok, err = custom_match_consumer(conf, jwt)
    if not ok then
      return ok, err
    end
  end

  -- Verify roles or scopes
  local ok, err = validate_scope(conf.scope, jwt.claims)

  if ok then
    ok, err = validate_realm_roles(conf.realm_roles, jwt.claims)
  end

  if ok then
    ok, err = validate_roles(conf.roles, jwt.claims)
  end

  if ok then
    ok, err = validate_client_roles(conf.client_roles, jwt.claims)
  end

  if ok then
    kong.ctx.shared.jwt_keycloak_token = jwt
    return true
  end

  return false, { status = 403, message = "Access token does not have the required scope/role: " .. err }
end


function JwtKeycloakHandler:access(conf)
  -- check if preflight request and whether it should be authenticated
  if not conf.run_on_preflight and kong.request.get_method() == "OPTIONS" then
    return
  end

  if conf.anonymous and kong.client.get_credential() then
    -- we're already authenticated, and we're configured for using anonymous,
    -- hence we're in a logical OR between auth methods and we're already done.
    return
  end

  local ok, err = do_authentication(conf)
  if not ok then
    if conf.anonymous then
      -- get anonymous user
      local consumer_cache_key = kong.db.consumers:cache_key(conf.anonymous)
      local consumer, err      = kong.cache:get(consumer_cache_key, nil,
                                                kong.client.load_consumer,
                                                conf.anonymous, true)
      if err then
        kong.log.err(err)
        return kong.response.exit(500, { message = "An unexpected error occurred during authentication" })
      end

      set_consumer(consumer)

    else
      return kong.response.exit(err.status, err.errors or { message = err.message })
    end
  end
end


return JwtKeycloakHandler
