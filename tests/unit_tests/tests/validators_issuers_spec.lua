local validate_issuer = require("kong.plugins.jwt-keycloak.validators.issuers").validate_issuer

local test_claims = {
    iss = "http://keycloak-headless/auth/realms/master"
}

describe("Validator", function()
    describe("for issuers should", function()
        it("handle when allowed issuers is nil", function()
            local valid, err = validate_issuer(nil, "")
            assert.same(nil, valid)
            assert.same("Allowed issuers is empty", err)
        end)

        it("handle when allowed issuers is empty list", function()
            local valid, err = validate_issuer({}, "")
            assert.same(nil, valid)
            assert.same("Allowed issuers is empty", err)
        end)

        it("handle when iss claim is missing", function()
            local valid, err = validate_issuer(
                {"http://keycloak-headless/auth/realms/master"}, 
                {}
            )
            assert.same(nil, valid)
            assert.same("Missing issuer claim", err)
        end)

        it("handle single valid issuer", function()
            local valid, err = validate_issuer(
                {"http://keycloak-headless/auth/realms/master"}, 
                test_claims
            )
            assert.same(true, valid)
        end)

        it("handle invalid issuer", function()
            local valid, err = validate_issuer(
                {"http://localhost:8080/auth/realms/master"}, 
                test_claims
            )
            assert.same(nil, valid)
            assert.same("Token issuer not allowed", err)
        end)

        it("handle multiple valid issuers", function()
            local valid, err = validate_issuer({
                "http://keycloak-headless/auth/realms/master",
                "http://localhost:8080/auth/realms/master"
            }, 
                test_claims
            )
            assert.same(true, valid)
        end)

        it("handle matching issuer", function()
            local valid, err = validate_issuer(
                {"http://keycloak%-headless/auth/realms/.+"}, 
                test_claims
            )
            assert.same(true, valid)
        end)
    end)
end)