{ pkgs, domain, ... }: {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = domain;
      database_backend = "rocksdb";
      allow_federation = true;
      allow_registration = false;
    };
  };
}

