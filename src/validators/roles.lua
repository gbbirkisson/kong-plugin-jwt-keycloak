local function validate_client_roles(allowed_client_roles, jwt_claims)
    if allowed_client_roles == nil or table.getn(allowed_client_roles) == 0 then
        return true
    end

    if jwt_claims == nil or jwt_claims.resource_access == nil then
        return nil, "Missing required resource_access claim"
    end

    for _, allowed_client_role in pairs(allowed_client_roles) do
        for curr_allowed_client, curr_allowed_role in string.gmatch(allowed_client_role, "(%S+):(%S+)") do
            for claim_client, claim_client_roles in pairs(jwt_claims.resource_access) do
                if curr_allowed_client == claim_client then
                    for _, curr_claim_client_roles in pairs(claim_client_roles) do
                        for _, curr_claim_client_role in pairs(curr_claim_client_roles) do
                            if curr_claim_client_role == curr_allowed_role then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    return nil, "Missing required role"
end

local function validate_roles(allowed_roles, jwt_claims)
    if allowed_roles == nil or table.getn(allowed_roles) == 0 then
        return true
    end

    if jwt_claims.azp == nil then
        return nil, "Missing required azp claim"
    end

    local tmp_allowed = {}
    for i, allowed in pairs(allowed_roles) do
        tmp_allowed[i] = jwt_claims.azp .. ":" .. allowed
    end
    
    return validate_client_roles(tmp_allowed, jwt_claims)
end

local function validate_realm_roles(allowed_realm_roles, jwt_claims)
    if allowed_realm_roles == nil or table.getn(allowed_realm_roles) == 0 then
        return true
    end

    if jwt_claims == nil or jwt_claims.realm_access == nil or jwt_claims.realm_access.roles == nil then
        return nil, "Missing required realm_access.roles claim"
    end

    for _, curr_claim_role in pairs(jwt_claims.realm_access.roles) do
        for _, curr_allowed_role in pairs(allowed_realm_roles) do
            if curr_claim_role == curr_allowed_role then
                return true
            end
        end
    end

    return nil, "Missing required realm role"
end

return {
    validate_client_roles = validate_client_roles,
    validate_realm_roles = validate_realm_roles,
    validate_roles = validate_roles
}
