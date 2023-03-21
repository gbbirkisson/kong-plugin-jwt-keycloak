local validate_client_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_client_roles

local test_claims = {
    resource_access = {
        account = {
            roles = {
                "manage-account",
                "manage-account-links",
                "view-profile"
            }
        }
    }
}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

describe("Validator", function()
    describe("for client roles should", function()
        it("handle a nil allowed roles", function()
            local valid = validate_client_roles(nil, test_claims)
            assert.same(true, valid)
        end)

        it("handle an empty list of allowed roles", function()
            local valid = validate_client_roles({}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a missing azp", function()
            local claims = deepcopy(test_claims)
            claims.resource_access = nil

            local valid, err = validate_client_roles({"test_role"}, claims)
            assert.same(nil, valid)
            assert.same("Missing required resource_access claim", err)
        end)

        it("handle a valid roles", function()
            local valid = validate_client_roles({"account:manage-account"}, test_claims)
            assert.same(true, valid)

            local valid = validate_client_roles({"account:valid_role", "account:view-profile"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a missing required role roles", function()
            local valid, err = validate_client_roles({"account:valid_role"}, test_claims)
            assert.same(nil, valid)
            assert.same("Missing required role", err)
        end)
    end)
end)