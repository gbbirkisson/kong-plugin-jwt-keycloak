local validate_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_roles

local test_claims = {
    azp = "test_client",
    resource_access = {
        test_client = {
            roles = {
                "test_role",
                "test_role_2"
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
    describe("for roles should", function()
        it("handle a nil allowed roles", function()
            local valid = validate_roles(nil, test_claims)
            assert.same(true, valid)
        end)

        it("handle an empty list of allowed roles", function()
            local valid = validate_roles({}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a missing azp", function()
            local claims = deepcopy(test_claims)
            claims.azp = nil

            local valid, err = validate_roles({"test_role"}, claims)
            assert.same(nil, valid)
            assert.same("Missing required azp claim", err)
        end)

        it("handle a valid roles", function()
            local valid = validate_roles({"test_role"}, test_claims)
            assert.same(true, valid)

            local valid = validate_roles({"valid_role", "test_role_2"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a missing required role roles", function()
            local valid, err = validate_roles({"test_role_invalid"}, test_claims)
            assert.same(nil, valid)
            assert.same("Missing required role", err)
        end)

        it("handle missing role list for azp", function()
            local claims = deepcopy(test_claims)
            claims.azp = "test_client_2"

            local valid, err = validate_roles({"test_role_2"}, claims)
            assert.same(nil, valid)
            assert.same("Missing required role", err)
        end)
    end)
end)