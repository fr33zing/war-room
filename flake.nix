{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs"; };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      settings = import ./settings.nix;
      myLib = import ./lib.nix;
    in {

      nixosConfigurations.war-room = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit (settings) domain email; };
        modules = [
          { nixpkgs.overlays = [ myLib.overlay ]; }
          ./configuration.nix
          ./modules/shell.nix
          ./modules/conduit.nix
          ./modules/nginx.nix
          ./modules/website.nix
        ];
      };

    } // (let
      withSystem = f:
        nixpkgs.lib.fold nixpkgs.lib.recursiveUpdate { }
        (map (s: f s) settings.systems);
    in withSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend myLib.overlay;
        inherit (pkgs) lib;
        tools = lib.my.readDevTools ./tools;
      in {

        devShells.${system}.default = pkgs.mkShell {
          packages = with pkgs; [ python3 matrix-conduit ] ++ tools;
          shellHook = ''
            printf '\n%s\n' '[Commands]'
            ${lib.my.shellHook.describeDevTools tools}
            printf '\n%s\n\n' '[Matrix]'
            ${lib.my.shellHook.startMatrixDevServer 6167}
          '';
        };

      }));
}
