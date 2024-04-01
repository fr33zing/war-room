rec {
  overlay = final: prev: {
    lib = prev.lib.extend (_: _: { my = functions prev; });
  };

  functions = nixpkgs:
    let inherit (nixpkgs) lib;
    in rec {

      filesIn = dir:
        builtins.attrNames
        (lib.filterAttrs (n: v: v == "regular") (builtins.readDir dir));

      dirsIn = dir:
        builtins.attrNames
        (lib.filterAttrs (n: v: v == "directory") (builtins.readDir dir));

      readDevTools = dir:
        map
        (file: nixpkgs.writeScriptBin file (builtins.readFile "${dir}/${file}"))
        (filesIn dir);

      # Functions that generate shell script
      shellHook = {
        describeDevTools = tools:
          builtins.concatStringsSep "\n" (map (tool:
            let
              command = nixpkgs.lib.getExe tool;
              name = builtins.baseNameOf command;
            in ''
              printf '%s: ' '${name}'
              ${command} --describe
            '') tools);

        startMatrixDevServer = port: ''
          export CONDUIT_CONFIG=${
            nixpkgs.writeText "conduit.toml" ''
              [global]
              database_path = "~/.local/share/conduit-dev"
              server_name = "localhost"
              address = "0.0.0.0"
              port = ${toString port}
              allow_registration = true
              allow_check_for_updates = false
              allow_federation = false
            ''
          }
          conduit &
          conduit_pid=$!
          trap "kill $conduit_pid" EXIT
          echo 'Conduit is running on port ${toString port}.'
          echo 'Matrix homeserver: http://localhost:${toString port}'
        '';
      };

      # https://github.com/numtide/flake-utils/blob/b1d9ab70662946ef0850d488da1c9019f3a9752a/lib.nix#L179
      mkApp = { drv, name ? drv.pname or drv.name
        , exePath ? drv.passthru.exePath or "/bin/${name}" }: {
          type = "app";
          program = "${drv}${exePath}";
        };

      packagesToApps = packages:
        builtins.mapAttrs (_: botPkg: mkApp { drv = botPkg; }) packages;

      readBots = dir: botArgs:
        lib.mergeAttrsList
        (map (bot: { ${bot} = import "${dir}/${bot}" botArgs; }) (dirsIn dir));

      listenOn = portSsls:
        lib.flatten (map (it:
          map (addr: {
            inherit (it) port ssl;
            inherit addr;
          }) [ "0.0.0.0" "[::]" ]) portSsls);

    };
}
