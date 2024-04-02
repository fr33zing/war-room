{ pkgs, domain, ... }: {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = domain;
      database_backend = "rocksdb";
      max_request_size = 1000000;
      allow_federation = true;
      allow_registration = false;
    };
  };
}

