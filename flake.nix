{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.war-room = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = let settings = import ./settings.nix;
      in { inherit (settings) domain email; };
      modules = [
        ./configuration.nix
        ./modules/shell.nix
        ./modules/matrix-conduit.nix
        ./modules/nginx.nix
      ];
    };
  };
}
