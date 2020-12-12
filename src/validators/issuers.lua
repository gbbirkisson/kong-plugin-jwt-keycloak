local function validate_issuer(allowed_issuers, jwt_claims)
    if allowed_issuers == nil or table.getn(allowed_issuers) == 0 then
        return nil, "Allowed issuers is empty"
    end
    if jwt_claims.iss == nil then
        return nil, "Missing issuer claim"
    end
    for _, curr_iss in pairs(allowed_issuers) do
        if curr_iss == jwt_claims.iss or string.match(jwt_claims.iss, curr_iss) ~= nil then
            return true
        end
    end
    return nil, "Token issuer not allowed"
end

return {
    validate_issuer = validate_issuer
}