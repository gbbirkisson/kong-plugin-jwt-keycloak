local httpc = require "resty.http".new()

-- function table_to_string(tbl)
--     local result = ""
--     for k, v in pairs(tbl) do
--         -- Check the key type (ignore any numerical keys - assume its an array)
--         if type(k) == "string" then
--             result = result.."[\""..k.."\"]".."="
--         end

--         -- Check the value type
--         if type(v) == "table" then
--             result = result..table_to_string(v)
--         elseif type(v) == "boolean" then
--             result = result..tostring(v)
--         else
--             result = result.."\""..v.."\""
--         end
--         result = result..","
--     end
--     -- Remove leading commas from the result
--     if result ~= "" then
--         result = result:sub(1, result:len()-1)
--     end
--     return result
-- end

local function get_issuer_keys(issuer)
    -- TODO: Call well known endpoint
    local res
    local err
    res, err = httpc:request_uri(issuer .. '/protocol/openid-connect/certs', {
        method = "GET",
        keepalive_timeout = 5,
        keepalive_pool = 5
    })
    
    if not res then
        return nil, 'Failed to get jwks_uri endpoint'
    end
    print("aa")
end

--keys, err = get_issuer_keys('http://localhost:8080/auth/realms/master')
-- print(table_to_string(keys[1]))
return {
    get_issuer_keys = get_issuer_keys
}