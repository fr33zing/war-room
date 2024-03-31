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
    } // withSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        filesIn = dir:
          builtins.attrNames
          (lib.filterAttrs (n: v: v == "regular") (builtins.readDir dir));
        tools = map (file:
          pkgs.writeScriptBin file (builtins.readFile (./tools + ("/" + file))))
          (filesIn ./tools);
      in {
        devShell.${system} = pkgs.mkShell {
          packages = with pkgs; [ python3 ] ++ tools;
          shellHook = ''
            printf '\n%s\n' '[Commands]'
          '' + (builtins.concatStringsSep "\n" (map (tool:
            let
              command = pkgs.lib.getExe tool;
              name = builtins.baseNameOf command;
            in ''
              printf '\n%s: ' '${name}'
              ${command} --describe
            '') tools));
        };
      }));
}
