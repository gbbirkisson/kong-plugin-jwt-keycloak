local validate_realm_roles = require("kong.plugins.jwt-keycloak.validators.roles").validate_realm_roles

local test_claims = {
    realm_access = {
        roles =  {
            "offline_access",
            "uma_authorization"
        }
    }
}

describe("Validator", function()
    describe("for roles should", function()
        it("handle a nil allowed roles", function()
            local valid = validate_realm_roles(nil, test_claims)
            assert.same(true, valid)
        end)

        it("handle an empty list of allowed roles", function()
            local valid = validate_realm_roles({}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a valid roles", function()
            local valid = validate_realm_roles({"offline_access"}, test_claims)
            assert.same(true, valid)

            local valid = validate_realm_roles({"valid_role", "uma_authorization"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a missing required role roles", function()
            local valid, err = validate_realm_roles({"test_role_invalid"}, test_claims)
            assert.same(nil, valid)
            assert.same("Missing required realm role", err)
        end)

        it("handle missing claim", function()
            local valid, err = validate_realm_roles({"test_role_2"}, {})
            assert.same(nil, valid)
            assert.same("Missing required realm_access.roles claim", err)
        end)
    end)
end)