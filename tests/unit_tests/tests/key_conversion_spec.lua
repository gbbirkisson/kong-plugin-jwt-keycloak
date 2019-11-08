-- local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")
-- local get_issuer_keys = keycloak_keys.get_issuer_keys
-- local get_wellknown_endpoint = keycloak_keys.get_wellknown_endpoint
-- local get_request = keycloak_keys.get_request

-- local well_known_template = "%s/.well-known/openid-configuration"

-- describe("Keycloak key conversion", function()
--   it("should convert the jwk to pem correctly", function()
--     local issuer = "http://localhost:8080/auth/realms/master"

--     res1, err1 = get_issuer_keys(get_wellknown_endpoint(well_known_template, issuer))
--     res2, err2 = get_request(issuer, "http")
    
--     assert.same(res2['public_key'], res1[1])
--   end)

--   it("should fail on invalid issuer", function()

--     local issuer = "http://localhost:8080/auth/realms/does_not_exist"

--     res1, err1 = get_issuer_keys(get_wellknown_endpoint(well_known_template, issuer))

--     assert.same(nil, res1)
--     assert.same('Failed calling url http://localhost:8080/auth/realms/does_not_exist/.well-known/openid-configuration response status 404', err1)
--   end)

--   it("should fail on bad issuer", function()
--     local issuer = "http://localhost:8081/auth/realms/does_not_exist"

--     res1, err1 = get_issuer_keys(get_wellknown_endpoint(well_known_template, issuer))

--     assert.same(nil, res1)
--     assert.same('Failed calling url http://localhost:8081/auth/realms/does_not_exist/.well-known/openid-configuration response status closed', err1)
--   end)

-- end)
