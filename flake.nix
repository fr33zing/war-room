{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs"; };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      settings = import ./settings.nix;

      withSystem = f:
        lib.fold lib.recursiveUpdate { } (map (s: f s) [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ]);
    in ({
      nixosConfigurations.war-room = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit (settings) domain email; };
        modules = [
          ./configuration.nix
          ./modules/shell.nix
          ./modules/matrix-conduit.nix
          ./modules/nginx.nix
        ];
      };
    } // withSystem (system: {
      devShell.${system} = nixpkgs.mkShell {
        # ...
      };
    }));
}
