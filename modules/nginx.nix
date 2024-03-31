{ config, pkgs, domain, email, ... }:
let
  inherit (pkgs) lib;

  matrixHostname = domain;

  conduitSettings = config.services.matrix-conduit.settings.global;

  well_known_server = pkgs.writeText "well-known-matrix-server" ''
    {
      "m.server": "${matrixHostname}"
    }
  '';
  well_known_client = pkgs.writeText "well-known-matrix-client" ''
    {
      "m.homeserver": {
        "base_url": "https://${matrixHostname}"
      }
    }
  '';
in {
  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];
  networking.firewall.allowedUDPPorts = [ 80 443 8448 ];

  security.acme = {
    acceptTerms = true;
    defaults = { inherit email; };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    upstreams = {
      "website" = { servers = { "[::1]:8787" = { }; }; };
      "conduit" = {
        servers = { "[::1]:${toString conduitSettings.port}" = { }; };
      };
    };

    virtualHosts = lib.recursiveUpdate {
      "${matrixHostname}" = {
        forceSSL = true;
        enableACME = true;

        listen = lib.my.listenOn [
          {
            port = 80;
            ssl = false;
          }
          {
            port = 443;
            ssl = true;
          }
          {
            port = 8448;
            ssl = true;
          }
        ];

        locations."/" = { proxyPass = "http://website$request_uri"; };

        locations."/_matrix/" = {
          proxyPass = "http://conduit$request_uri";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_buffering off;
          '';
        };

        extraConfig = ''
          merge_slashes off;
        '';
      };
    } {
      "${conduitSettings.server_name}" = {
        forceSSL = true;
        enableACME = true;

        locations."=/.well-known/matrix/server" = {
          alias = "${well_known_server}";
          extraConfig = ''
            default_type application/json;
          '';
        };

        locations."=/.well-known/matrix/client" = {
          alias = "${well_known_client}";
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
          '';
        };
      };
    };
  };
}
