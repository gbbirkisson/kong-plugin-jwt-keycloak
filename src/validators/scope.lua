local function dump(o)
    if type(o) == 'table' then
       local s = ''
       for _, v in pairs(o) do
          --if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. dump(v) .. ' '
       end
       return s
    else
       return tostring(o)
    end
end

local function validate_scope(scope_claim, allowed_scopes, jwt_claims)

    if allowed_scopes == nil or table.getn(allowed_scopes) == 0 then
        return true
    end

    if jwt_claims == nil or jwt_claims[scope_claim] == nil then
        return nil, "Missing required scope claim"
    end

    local claimed_scopes = dump(jwt_claims[scope_claim])

    -- If statment a hack to pass unit tests
    if kong then
        kong.service.request.add_header("x-consumer-scopes", claimed_scopes:sub(1,-2):gsub(" ", ","))
    end

    for scope in string.gmatch(claimed_scopes, "%S+") do
        for _, curr_scope in pairs(allowed_scopes) do
            if scope == curr_scope then
                return true
            end
        end
    end
    return nil, "Missing required scope"
end

return {
    validate_scope = validate_scope
}


