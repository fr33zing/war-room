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

      describeDevTools = tools:
        builtins.concatStringsSep "\n" (map (tool:
          let
            command = nixpkgs.lib.getExe tool;
            name = builtins.baseNameOf command;
          in ''
            printf '\n%s: ' '${name}'
            ${command} --describe
          '') tools);

      listenOn = portSsls:
        lib.flatten (map (it:
          map (addr: {
            inherit (it) port ssl;
            inherit addr;
          }) [ "0.0.0.0" "[::]" ]) portSsls);

    };
}
