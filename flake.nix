{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    # Used for packaging bots written in Rust
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
        bots = lib.my.readBots ./bots { inherit inputs pkgs system; };
      in rec {

        packages.${system}.bots = bots;
        apps.${system}.bots = lib.my.packagesToApps bots;

        devShells.${system} = {
          default = pkgs.mkShell {
            packages = with pkgs; [ python3 matrix-conduit ] ++ tools;
            shellHook = let conduitPort = 6167;
            in ''
              export FLAKE_DIR="${./.}"
              export BOTS_DIR="${./bots}"
              export CONDUIT_PORT="${toString conduitPort}"

              printf '\n%s\n\n' '[Commands]'
              ${lib.my.shellHook.describeDevTools tools}
              printf '\n%s\n\n' '[Matrix]'
              ${lib.my.shellHook.startMatrixDevServer conduitPort}
            '';
          };

          rust = inputs.crane.lib.${system}.devShell { };
        };
      }));
}
