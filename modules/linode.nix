{
  boot = {
    kernelParams = [ "console=ttyS0,19200n8" ];
    loader = {
      timeout = 10;
      grub = {
        forceInstall = true;
        device = "nodev";
        extraConfig = ''
          serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
          terminal_input serial;
          terminal_output serial
        '';
      };
    };
  };
}
