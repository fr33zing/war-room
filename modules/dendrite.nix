{ config, domain, ... }: {
  services.postgresql.enable = true;

  users.groups.dendrite = { };
  users.users.dendrite = {
    isSystemUser = true;
    name = "dendrite";
    group = "dendrite";
  };

  services.dendrite = {
    enable = true;
    environmentFile = config.sops.secrets."dendrite_env".path;

    settings = {
      global = {
        server_name = domain;
        private_key = config.sops.secrets."matrix_key".path;
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
