describe("Keycloak key conversion", function()

  it("should convert the jwk to pem correctly", function()
    local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")
    local issuer = "http://localhost:8080/auth/realms/master"

    res1, err1 = keycloak_keys.get_issuer_keys(issuer)
    res2, err2 = keycloak_keys.get_request(issuer)
    
    assert.same(res2['public_key'], res1[1])
  end)

  it("should fail on invalid issuer", function()
    local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")
    local issuer = "http://localhost:8080/auth/realms/does_not_exist"

    res1, err1 = keycloak_keys.get_issuer_keys(issuer)

    assert.same(nil, res1)
    assert.same('Failed calling url http://localhost:8080/auth/realms/does_not_exist/protocol/openid-connect/certs', err1)
  end)

  it("should fail on bad issuer", function()
    local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")
    local issuer = "http://localhost:8081/auth/realms/does_not_exist"

    res1, err1 = keycloak_keys.get_issuer_keys(issuer)

    assert.same(nil, res1)
    assert.same('Failed calling url http://localhost:8081/auth/realms/does_not_exist/protocol/openid-connect/certs', err1)
  end)

end)

-- describe("Key split and combining", function()

--   it("should work on a single key", function()
--     local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")

--     a = {"a"}
--     keys = keycloak_keys.combine_issuer_keys(a)
--     assert.same("a", keys)

--     keys = keycloak_keys.split_issuer_keys(keys)
--     assert.same(1, table.getn(keys))
--     assert.same("a", keys[1])
--   end)

--   it("should work on a multiple keys", function()
--     local keycloak_keys = require("kong.plugins.jwt-keycloak.keycloak_keys")

--     a = {"a", "b", "c"}
--     keys = keycloak_keys.combine_issuer_keys(a)
--     assert.same("a\nb\nc", keys)

--     keys = keycloak_keys.split_issuer_keys(keys)
--     assert.same(3, table.getn(keys))
--     assert.same("a", keys[1])
--     assert.same("b", keys[2])
--     assert.same("c", keys[3])
--   end)

-- end)