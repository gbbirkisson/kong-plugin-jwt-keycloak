return {

    postgres = {
        up = [[
            CREATE TABLE IF NOT EXISTS jwt_keycloak_public_keys(
                id uuid,
                iss text,
                public_key text,
                created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
                PRIMARY KEY (id)
            );
            DO $$
            BEGIN
                IF (SELECT to_regclass('jwt_keycloak_public_keys_idx')) IS NULL THEN
                    CREATE INDEX jwt_keycloak_public_keys_idx ON jwt_keycloak_public_keys(iss);
                END IF;
            END$$;
        ]],
    },

    cassandra = {
        up = [[
            CREATE TABLE IF NOT EXISTS jwt_keycloak_public_keys(
                id uuid,
                iss text,
                public_key text,
                created_at timestamp,
                PRIMARY KEY (id)
            );
            CREATE INDEX IF NOT EXISTS ON jwt_keycloak_public_keys(iss);
        ]],
    },

}
