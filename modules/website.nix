{
  environment.etc.website.source = ../website;
  services.static-web-server = {
    enable = true;
    listen = "[::]:8787";
    root = "/etc/website";
  };
}
