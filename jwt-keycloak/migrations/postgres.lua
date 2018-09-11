return {
    {
        name = "2018-09-08-132400_init_jwt_keycloak",
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
        IF (SELECT to_regclass('basicauth_iss_idx')) IS NULL THEN
          CREATE INDEX basicauth_iss_idx ON jwt_keycloak_public_keys(iss);
        END IF;
      END$$;
    ]],
        down = [[
      DROP TABLE jwt_keycloak_public_keys;
    ]]
    }
} 