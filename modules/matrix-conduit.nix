{ pkgs, domain, ... }: {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = domain;
      allow_federation = false;
      allow_registration = true;
    };
  };
}
