{ config, lib, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  users.users.user = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [ vim ];

  system.stateVersion = "23.11";
}

