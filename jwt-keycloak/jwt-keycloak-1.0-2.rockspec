package = "jwt-keycloak"
version = "1.0-2"
source = {
  url = "TBD"
}
description = {
  summary = "A Kong plugin that will validate tokens issued by keycloak",
  license = "MIT"
}
dependencies = {
  "lua ~> 5"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.jwt-keycloak.migrations.init"] = "migrations/init.lua",
    ["kong.plugins.jwt-keycloak.migrations.000_base_jwt_keycloak"] = "migrations/000_base_jwt_keycloak.lua",
    ["kong.plugins.jwt-keycloak.api"]  = "api.lua",
    ["kong.plugins.jwt-keycloak.daos"]  = "daos.lua",
    ["kong.plugins.jwt-keycloak.schema"]  = "schema.lua",
    ["kong.plugins.jwt-keycloak.handler"] = "handler.lua",
    ["kong.plugins.jwt-keycloak.keycloak_keys"] = "keycloak_keys.lua"
  }
}