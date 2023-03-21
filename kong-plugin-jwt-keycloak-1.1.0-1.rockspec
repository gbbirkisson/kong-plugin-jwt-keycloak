local plugin_name = "jwt-keycloak"
local package_name = "kong-plugin-" .. plugin_name

package = package_name

version = "1.1.0-1"
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

supported_platforms = {"linux", "macosx"}

source = {
  url = "git://github.com/gbbirkisson/kong-plugin-jwt-keycloak",
  tag = "v1.1.0",
}
description = {
  summary = "A Kong plugin that will validate tokens issued by keycloak",
  homepage = "https://github.com/gbbirkisson/kong-plugin-jwt-keycloak",
  license = "Apache 2.0"
}
dependencies = {
  "lua ~> 5"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".validators.issuers"] = "kong/plugins/"..plugin_name.."/validators/issuers.lua",
    ["kong.plugins."..plugin_name..".validators.roles"] = "kong/plugins/"..plugin_name.."/validators/roles.lua",
    ["kong.plugins."..plugin_name..".validators.scope"] = "kong/plugins/"..plugin_name.."/validators/scope.lua",
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".key_conversion"] = "kong/plugins/"..plugin_name.."/key_conversion.lua",
    ["kong.plugins."..plugin_name..".keycloak_keys"] = "kong/plugins/"..plugin_name.."/keycloak_keys.lua",
    ["kong.plugins."..plugin_name..".schema"]  = "kong/plugins/"..plugin_name.."/schema.lua",
  }
}