{ config, pkgs, domain, email, ... }:
let
  inherit (pkgs) lib;

  matrixHostname = domain;
  matrixServerName = config.services.dendrite.settings.global.server_name;
  matrixPort = config.services.dendrite.httpPort;
  firewallOpenPorts = [ 80 443 8448 ];

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
  networking.firewall.allowedTCPPorts = firewallOpenPorts;
  networking.firewall.allowedUDPPorts = firewallOpenPorts;

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
      "matrix" = { servers = { "[::1]:${toString matrixPort}" = { }; }; };
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
          proxyPass = "http://matrix$request_uri";
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
      "${matrixServerName}" = {
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
