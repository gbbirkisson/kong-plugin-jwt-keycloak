local crud = require "kong.api.crud_helpers"
local singletons = require "kong.singletons"

return {
    ["/jwt-keycloak"] = {
        GET = function(self, dao_factory)
            crud.paginated_set(self, dao_factory.jwt_keycloak_public_keys)
        end,

        POST = function(self, dao_factory)
            -- TODO: DO NOT ALLOW DUPLICATE ENTRIES
            crud.post(self.params, dao_factory.jwt_keycloak_public_keys)
        end
    },
    ["/jwt-keycloak/:id"] = {
        before = function(self, dao_factory, helpers)

            local iss, err = crud.find_by_id_or_field(
                    dao_factory.jwt_keycloak_public_keys,
                    nil,
                    ngx.unescape_uri(self.params.id),
                    "iss"
            )

            if err then
                return helpers.yield_error(err)
            elseif next(iss) == nil then
                return helpers.responses.send_HTTP_NOT_FOUND()
            end
            self.iss = iss[1]
        end,

        GET = function(self, dao_factory, helpers)
            return helpers.responses.send_HTTP_OK(self.iss)
        end,

        PATCH = function(self, dao_factory)
            singletons.cache:invalidate("iss_cache_" .. self.iss.iss)
            crud.patch(self.params, dao_factory.jwt_keycloak_public_keys, self.iss)
        end,

        DELETE = function(self, dao_factory)
            singletons.cache:invalidate("iss_cache_" .. self.iss.iss)
            crud.delete(self.iss, dao_factory.jwt_keycloak_public_keys)
        end
    }
}
