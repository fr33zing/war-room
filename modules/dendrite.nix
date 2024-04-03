{ config, domain, ... }: {
  services.postgresql.enable = true;

  services.dendrite = {
    enable = true;
    environmentFile = "/run/secrets/dendrite_env";

    settings = {
      global = {
        server_name = domain;
        private_key = "/run/secrets/matrix_key";
        database = {
          connection_string = "$CONNECTION_STRING";
          max_open_conns = 90;
          max_idle_conns = 5;
          conn_max_lifetime = -1;
        };
      };

      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";

      # Disable sqlite databases
      app_service_api.database.connection_string = "";
      federation_api.database.connection_string = "";
      key_server.database.connection_string = "";
      media_api.database.connection_string = "";
      mscs.database.connection_string = "";
      relay_api.database.connection_string = "";
      room_server.database.connection_string = "";
      sync_api.database.connection_string = "";
      user_api.database.connection_string = "";
      user_api.account_database.connection_string = "";
      user_api.device_database.connection_string = "";
    };
  };
}
