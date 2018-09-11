return {
  {
    name = "2018-09-08-132400_init_jwt_keycloak",
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
    down = [[
      DROP TABLE jwt_keycloak_public_keys;
    ]]
  }
}