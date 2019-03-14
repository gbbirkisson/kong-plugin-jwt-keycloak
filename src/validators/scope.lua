local function validate_scope(allowed_scopes, jwt_claims)
    if allowed_scopes == nil or table.getn(allowed_scopes) == 0 then
        return true
    end

    if jwt_claims == nil or jwt_claims.scope == nil then
        return nil, "Missing required scope claim"
    end

    for _, curr_scope in pairs(allowed_scopes) do
        if string.find(jwt_claims.scope, curr_scope) then
            return true
        end
    end
    return nil, "Missing required scope"
end

return {
    validate_scope = validate_scope
}