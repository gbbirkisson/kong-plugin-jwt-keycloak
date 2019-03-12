local http = require "socket.http"
local cjson_safe = require "cjson.safe"
local convert = require "kong.plugins.jwt-keycloak.key_conversion"

local function get_request(url)
    local res
    local status

    res, status = http.request(url)
    
    if status ~= 200 then
        return nil, 'Failed calling url ' .. url
    end

    res, err = cjson_safe.decode(res)
    if not res then
        return nil, 'Failed to parse json response'
    end
    
    return res, nil

end

local function get_issuer_keys(issuer)
    local res, err = get_request(issuer .. '/protocol/openid-connect/certs')
    if err then
        return nil, err
    end

    keys = {}
    for i, key in ipairs(res['keys']) do
        keys[i] = string.gsub(
            convert.convert_kc_key(key), 
            "[\r\n]+", ""
        )
    end
    return keys, nil
end

-- local key_seperator = "\n"

-- local function combine_issuer_keys(keys)
--     res = ""
--     sep = ""
--     for i, key in ipairs(keys) do
--         res = res .. sep .. key
--         sep = key_seperator
--     end
--     return res
-- end

-- local function split_issuer_keys(key_string)
--     result = {};
--     for match in (key_string..key_seperator):gmatch("(.-)"..key_seperator) do
--         table.insert(result, match);
--     end
--     return result;
-- end

return {
    get_request = get_request,
    get_issuer_keys = get_issuer_keys,
    -- split_issuer_keys = split_issuer_keys,
    -- combine_issuer_keys = combine_issuer_keys
}