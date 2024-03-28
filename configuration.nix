{ config, lib, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  users.users.user = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [ vim git ];

  system.stateVersion = "23.11";
}

