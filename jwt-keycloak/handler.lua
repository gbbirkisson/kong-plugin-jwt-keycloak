local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local singletons = require "kong.singletons"
local constants = require "kong.constants"

local ngx_re_gmatch = ngx.re.gmatch
local get_method = ngx.req.get_method
local ngx_set_header = ngx.req.set_header

local JwtKeycloakHandler = BasePlugin:extend()

JwtKeycloakHandler.PRIORITY = 1005

function table_to_string(tbl)
    local result = ""
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
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

local function retrieve_token(request, conf)
  local uri_parameters = request.get_uri_args()

  for _, v in ipairs(conf.uri_param_names) do
    if uri_parameters[v] then
      return uri_parameters[v]
    end
  end

  local ngx_var = ngx.var
  for _, v in ipairs(conf.cookie_names) do
    local jwt_cookie = ngx_var["cookie_" .. v]
    if jwt_cookie and jwt_cookie ~= "" then
      return jwt_cookie
    end
  end

  local authorization_header = request.get_headers()["authorization"]
  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, iter_err
    end

    local m, err = iterator()
    if err then
      return nil, err
    end

    if m and #m > 0 then
      return m[1]
    end
  end
end

local function load_public_key(iss)
    local pk, err = singletons.dao.jwt_keycloak_public_keys:find_all { iss = iss }

    if err then
        return nil, err
    end

    return jwt_decoder:b64_decode(pk[1].public_key)
end

local function match_public_key(iss)
    local iss_cache_key = "iss_cache_" .. iss
    local public_key, err = singletons.cache:get(iss_cache_key, nil, load_public_key, iss, true)
    if err then
        return err
    end

    if not public_key then
        return string_format("Could not find public key for 'iss=%s'", iss)
    end

    return false, public_key
end

local function load_consumer_by_id(consumer_id)
    local result, err = singletons.db.consumers:select { id = consumer_id }

    if not result then
        return nil, 'Consumer "' .. consumer_id .. '" not found'
    end
    return result
end

local function load_consumer_by_custom_id(jwt, conf)
    local result, _, err = singletons.db.consumers:select_by_custom_id(jwt.claims[conf.consumer_match_claim])

    if not result then
        return nil, 'Consumer "' .. custom_id .. '" not found'
    end
    return result
end

local function set_consumer(consumer, token)
    ngx_set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
    ngx_set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
    ngx_set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
    ngx.ctx.authenticated_consumer = consumer
    ngx.ctx.authenticated_jwt_token = token
    ngx_set_header(constants.HEADERS.ANONYMOUS, nil) -- in case of auth plugins concatenation
end

local function match_consumer(jwt, conf)
    local consumer_id = jwt.claims[conf.consumer_match_claim]
    local consumer_cache_key = consumer_id

    local consumer, err = singletons.cache:get(consumer_cache_key, nil, load_consumer_by_id, consumer_id)
    if err then
        return false, err
    end

    if not consumer then
        return false, string_format("Could not find consumer for '%s=%s'", conf.consumer_match_claim, consumer_id)
    end

    return consumer
end

local function verify_token(conf)
    -- DONE
    local token, err = retrieve_token(ngx.req, conf)
    if err then
        return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    -- DONE
    local ttype = type(token)
    if ttype ~= "string" then
        if ttype == "nil" then
            return false, { status = 401, message = "Missing access token" }
        elseif ttype == "table" then
            return false, { status = 401, message = "Multiple tokens provided" }
        else
            return false, { status = 401, message = "Unrecognizable token" }
        end
    end

    -- DONE
    local jwt, err = jwt_decoder:new(token)
    if err then
        return false, { status = 401, message = "Bad token; " .. tostring(err) }
    end

    -- DONE
    -- Verify "alg"
    local algorithm = conf.algorithm or "HS256"
    if jwt.header.alg ~= algorithm then
        return false, { status = 401, message = "Invalid token algorithm" }
    end

    -- DONE
    -- Verify the JWT registered claims
    local ok_claims, errors = jwt:verify_registered_claims(conf.claims_to_verify)
    if not ok_claims then
        return false, { status = 401, message = "Token claims invalid: " .. table_to_string(errors) }
    end

    -- DONE
    -- Verify the JWT registered claims
    if conf.maximum_expiration ~= nil and conf.maximum_expiration > 0 then
        local ok, errors = jwt:check_maximum_expiration(conf.maximum_expiration)
        if not ok then
            return false, { status = 401, message = "Token claims invalid: " .. table_to_string(errors) }
        end
    end

    -- Verify that the issuer is allowed
    local iss_allowed = false
    if conf.allowed_iss then
        for k, v in pairs(conf.allowed_iss) do
            if string.match(v, "^" .. jwt.claims.iss .. "$") then
                iss_allowed = true
            end
        end
    end

    if not conf.allow_all_iss and not iss_allowed then
        return false, { status = 401, message = "Token issuer not allowed for this api" }
    end

    -- DONE
    local err, public_key = match_public_key(jwt.claims.iss)

    if err then
        return false, { status = 401, message = "Unable to get public key for issuer" }
    end

    -- DONE
    -- Verify signature
    if not jwt:verify_signature(public_key) then
        return false, { status = 401, message = "Invalid token signature" }
    end

    -- Match consumer
    if conf.consumer_match then
        local consumer_found, err
        if conf.consumer_match_claim_custom_id then
            -- This call is not cached
            consumer_found, err = load_consumer_by_custom_id(jwt, conf)
        else
            -- This call is cached
            consumer_found, err = match_consumer(jwt, conf)
        end
        if not consumer_found and not conf.consumer_match_ignore_not_found then
            return false, { status = 401, message = "Unable to find consumer for token" }
        end
        if consumer_found then
            set_consumer(consumer_found, token)
        end
    end

    -- If no roles to verify
    if not conf.roles and not conf.realm_roles and not conf.client_roles then
        return true
    end

    -- Verify roles
    if conf.roles ~= nil and jwt.claims ~= nil and jwt.claims.resource_access ~= nil and jwt.claims.resource_access[jwt.claims.azp] ~= nil and jwt.claims.resource_access[jwt.claims.azp].roles ~= nil then
        local t_roles = jwt.claims.resource_access[jwt.claims.azp].roles

        for k, v in pairs(t_roles) do
            for _, role_pattern in pairs(conf.roles) do
                if string.match(v, "^" .. role_pattern .. "$") then
                    return true
                end
            end
        end
    end

    -- Verify realm roles
    if conf.realm_roles ~= nil and jwt.claims ~= nil and jwt.claims.realm_access ~= nil and jwt.claims.realm_access.roles ~= nil then
        local r_roles = jwt.claims.realm_access.roles

        for k, v in pairs(r_roles) do
            for _, role_pattern in pairs(conf.realm_roles) do
                if string.match(v, "^" .. role_pattern .. "$") then
                    return true
                end
            end
        end
    end

    -- Verify client roles
    if conf.client_roles ~= nil and jwt.claims ~= nil and jwt.claims.resource_access ~= nil then
        local cli_roles = jwt.claims.resource_access

        -- Iterate over 'resource_access' object in token
        for t_client, t_obj in pairs(cli_roles) do
            -- Iterate over provided client roles
            for _, role_pattern in pairs(conf.client_roles) do
                -- Split client roles into client name and client role
                for c_name, c_roles in string.gmatch(role_pattern, "(%S+):(%S+)") do
                    -- If client name matches provided client name
                    if string.match(t_client, c_name) then
                        -- Iterate over token client roles
                        for k, v in pairs(t_obj.roles) do
                            -- Try to match token role to provided role
                            if v == c_roles then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    return false, { status = 403, message = "Access token does not have the required scope/role" }
end

function JwtKeycloakHandler:new()
    JwtKeycloakHandler.super.new(self, "jwt-keycloak")
end

function JwtKeycloakHandler:access(conf)
    JwtKeycloakHandler.super.access(self)

    if not conf.run_on_preflight and get_method() == "OPTIONS" then
        return
    end

    local ok, err = verify_token(conf)
    if not ok then
        return responses.send(err.status, err.message)
    end

end

return JwtKeycloakHandler
