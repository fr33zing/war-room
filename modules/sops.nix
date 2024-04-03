{ config, ... }: {
  sops = {
    defaultSopsFile = ../secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/user/.config/sops/age/keys.txt";
    secrets = {
      dendrite_env = {
        owner = config.users.users.dendrite.name;
        group = config.users.users.dendrite.name;
        mode = "0440";
      };
      matrix_key = {
        owner = config.users.users.dendrite.name;
        group = config.users.users.dendrite.name;
        mode = "0440";
      };
    };
  };
}
