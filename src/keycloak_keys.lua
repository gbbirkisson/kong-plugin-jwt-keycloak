local https = require "ssl.https"
local cjson_safe = require "cjson.safe"
local convert = require "kong.plugins.jwt-keycloak.key_conversion"

local function parse_url(url)
    local chunk, protocol = url:match("^(([a-z0-9+]+)://)")
    url = url:sub((chunk and #chunk or 0) + 1)

    local auth
    chunk, auth = url:match('(([%w%p]+:?[%w%p]+)@)')
    url = url:sub((chunk and #chunk or 0) + 1)

    local host
    local hostname
    local port
    if protocol then
        host = url:match("^([%a%.%d-]+:?%d*)")
        if host then
            hostname = host:match("^([^:/]+)")
            port = host:match(":(%d+)$")
        end
        url = url:sub((host and #host or 0) + 1)
    end

    local parsed = {
        protocol = protocol,
        host = host,
        hostname = hostname,
        port = port,
    }

    return parsed
end

local function get_request(url, port)
    local res
    local status
    local err

    local chunks = {}
    res, status = https.request{
        url = url,
        port = port,
        sink = ltn12.sink.table(chunks)
    }
    
    if status ~= 200 then
        return nil, 'Failed calling url ' .. url
    end

    res, err = cjson_safe.decode(table.concat(chunks))
    if not res then
        return nil, 'Failed to parse json response'
    end
    
    return res, nil
end

local function get_wellknown_endpoint(well_known_template, issuer)
    return string.format(well_known_template, issuer)
end

local function get_issuer_keys(well_known_endpoint)
    -- Get port of the request: This is done because keycloak 3.X.X does not play well with lua socket.http
    local req = parse_url(well_known_endpoint)

    local res, err = get_request(well_known_endpoint, req.port)
    if err then
        return nil, err
    end

    local res, err = get_request(res['jwks_uri'], req.port)
    if err then
        return nil, err
    end

    local keys = {}
    for i, key in ipairs(res['keys']) do
        keys[i] = string.gsub(
            convert.convert_kc_key(key), 
            "[\r\n]+", ""
        )
    end
    return keys, nil
end

return {
    get_request = get_request,
    get_issuer_keys = get_issuer_keys,
    get_wellknown_endpoint = get_wellknown_endpoint,
}