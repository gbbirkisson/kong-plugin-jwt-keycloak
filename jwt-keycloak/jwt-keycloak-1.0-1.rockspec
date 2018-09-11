package = "jwt-keycloak"
version = "1.0-1"
source = {
  url = "TBD"
}
description = {
  summary = "A Kong plugin that will validate tokens issued by keycloak",
  license = "MIT"
}
dependencies = {
  "lua ~> 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.jwt-keycloak.migrations.cassandra"] = "migrations/cassandra.lua",
    ["kong.plugins.jwt-keycloak.migrations.postgres"] = "migrations/postgres.lua",
    ["kong.plugins.jwt-keycloak.api"]  = "api.lua",
    ["kong.plugins.jwt-keycloak.daos"]  = "daos.lua",
    ["kong.plugins.jwt-keycloak.schema"]  = "schema.lua",
    ["kong.plugins.jwt-keycloak.handler"] = "handler.lua"
  }
}