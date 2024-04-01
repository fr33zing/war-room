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
              printf '\n%s: ' '${name}'
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

      listenOn = portSsls:
        lib.flatten (map (it:
          map (addr: {
            inherit (it) port ssl;
            inherit addr;
          }) [ "0.0.0.0" "[::]" ]) portSsls);

    };
}
