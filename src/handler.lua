local BasePlugin = require "kong.plugins.base_plugin"
local constants = require "kong.constants"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local socket = require "socket"
local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")

local re_gmatch = ngx.re.gmatch

local JwtKeycloakHandler = BasePlugin:extend()

JwtKeycloakHandler.PRIORITY = 1005
JwtKeycloakHandler.VERSION = "1.0.0"

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

--- Retrieve a JWT in a request.
-- Checks for the JWT in URI parameters, then in cookies, and finally
-- in the `Authorization` header.
-- @param request ngx request object
-- @param conf Plugin configuration
-- @return token JWT token contained in request (can be a table) or nil
-- @return err
local function retrieve_token(conf)
    local args = kong.request.get_query()
    for _, v in ipairs(conf.uri_param_names) do
        if args[v] then
            return args[v]
        end
    end

    local var = ngx.var
    for _, v in ipairs(conf.cookie_names) do
        local cookie = var["cookie_" .. v]
        if cookie and cookie ~= "" then
            return cookie
        end
    end

    local authorization_header = kong.request.get_header("authorization")
    if authorization_header then
        local iterator, iter_err = re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
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

function JwtKeycloakHandler:new()
    JwtKeycloakHandler.super.new(self, "jwt-keycloak")
end

local function load_consumer(consumer_id, anonymous)
    local result, err = kong.db.consumers:select { id = consumer_id }
    if not result then
        if anonymous and not err then
            err = 'anonymous consumer "' .. consumer_id .. '" not found'
        end
        return nil, err
    end
    return result
end

local function load_consumer_by_custom_id(custom_id)
    local result, err = kong.db.consumers:select_by_custom_id(custom_id)
    if not result then
        return nil, err
    end
    return result
end

local function set_consumer(consumer, credential, token)
    local set_header = kong.service.request.set_header
    local clear_header = kong.service.request.clear_header

    if consumer and consumer.id then
        set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
    else
        clear_header(constants.HEADERS.CONSUMER_ID)
    end

    if consumer and consumer.custom_id then
        set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
    else
        clear_header(constants.HEADERS.CONSUMER_CUSTOM_ID)
    end

    if consumer and consumer.username then
        set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
    else
        clear_header(constants.HEADERS.CONSUMER_USERNAME)
    end

    kong.client.authenticate(consumer, credential)

    if credential then
        kong.ctx.shared.authenticated_jwt_token = token -- TODO: wrap in a PDK function?
        ngx.ctx.authenticated_jwt_token = token  -- backward compatibilty only

        if credential.username then
            set_header(constants.HEADERS.CREDENTIAL_USERNAME, credential.username)
        else
            clear_header(constants.HEADERS.CREDENTIAL_USERNAME)
        end

        clear_header(constants.HEADERS.ANONYMOUS)

    else
        clear_header(constants.HEADERS.CREDENTIAL_USERNAME)
        set_header(constants.HEADERS.ANONYMOUS, true)
    end
end

local function get_keys(well_known_endpoint)
    kong.log.debug('Getting public keys from keycloak')
    keys, err = keycloak_keys.get_issuer_keys(well_known_endpoint)
    if err then
        return nil, err
    end

    decoded_keys = {}
    for i, key in ipairs(keys) do
        decoded_keys[i] = jwt_decoder:base64_decode(key)
    end
    
    kong.log.debug('Number of keys retrieved: ' .. table.getn(decoded_keys))
    return {
        keys = decoded_keys,
        updated_at = socket.gettime(),
    }
end

local function validate_signature(conf, jwt, second_call)
    local issuer_cache_key = 'issuer_keys_' .. jwt.claims.iss
    
    well_known_endpoint = keycloak_keys.get_wellknown_endpoint(conf.well_known_template, jwt.claims.iss)
    -- Retrieve public keys
    local public_keys, err = kong.cache:get(issuer_cache_key, nil, get_keys, well_known_endpoint, true)

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
    since_last_update = socket.gettime() - public_keys.updated_at
    if not second_call and since_last_update > conf.iss_key_grace_period then
        kong.log.debug('Could not validate signature. Keys updated last ' .. since_last_update .. ' seconds ago')
        kong.cache:invalidate_local(issuer_cache_key)
        return validate_signature(conf, jwt, true)
    end

    return kong.response.exit(401, { message = "Invalid token signature" })
end

local function do_authentication(conf)
    -- Retrieve token
    local token, err = retrieve_token(conf)
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

    -- Decode token
    local jwt, err = jwt_decoder:new(token)
    if err then
        return false, { status = 401, message = "Bad token; " .. tostring(err) }
    end

    -- Verify algorithim
    if jwt.header.alg ~= (conf.algorithm or "HS256") then
        return false, {status = 403, message = "Invalid algorithm"}
    end

    -- Verify the JWT registered claims
    local ok_claims, errors = jwt:verify_registered_claims(conf.claims_to_verify)
    if not ok_claims then
        return false, { status = 401, message = "Token claims invalid: " .. table_to_string(errors) }
    end

    -- Verify maximum expiration
    if conf.maximum_expiration ~= nil and conf.maximum_expiration > 0 then
        local ok, errors = jwt:check_maximum_expiration(conf.maximum_expiration)
        if not ok then
            return false, { status = 403, message = "Token claims invalid: " .. table_to_string(errors) }
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

    if not iss_allowed then
        return false, { status = 401, message = "Token issuer not allowed" }
    end

    err = validate_signature(conf, jwt)
    if err ~= nil then
        return false, err
    end

    -- Match consumer
    if conf.consumer_match then
        local consumer, err
        local consumer_id = jwt.claims[conf.consumer_match_claim]

        if conf.consumer_match_claim_custom_id then
            consumer_cache_key = "custom_id_key_" .. consumer_id
            consumer, err = kong.cache:get(consumer_cache_key, nil, load_consumer_by_custom_id, consumer_id, true)
        else
            consumer_cache_key = kong.db.consumers:cache_key(consumer_id)
            consumer, err = kong.cache:get(consumer_cache_key, nil, load_consumer, consumer_id, true)
        end

        if err then
            kong.log.err(err)
        end

        if not consumer and not conf.consumer_match_ignore_not_found then
            return false, { status = 401, message = "Unable to find consumer for token" }
        end

        if consumer then
            set_consumer(consumer, nil, nil)
        end

    end

    kong.log.debug('Verify roles/scope')
    
    -- If no roles to verify
    if not conf.roles and not conf.realm_roles and not conf.client_roles and not conf.scope then
        kong.log.debug('No roles/scope to verify')
        return true
    end

    -- Verify scope
    if conf.scope ~= nil and jwt.claims.scope ~= nil then
        for _, scope_pattern in pairs(conf.scope) do
            if string.find(jwt.claims.scope, scope_pattern) then
                return true
            end
        end
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


function JwtKeycloakHandler:access(conf)
    JwtKeycloakHandler.super.access(self)

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
                                                    load_consumer,
                                                    conf.anonymous, true)
            if err then
                kong.log.err(err)
                return kong.response.exit(500, { message = "An unexpected error occurred" })
            end

            set_consumer(consumer, nil, nil)
        else
            return kong.response.exit(err.status, err.errors or { message = err.message })
        end
    end
end

return JwtKeycloakHandler
