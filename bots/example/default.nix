{ inputs, pkgs, system }:
let craneLib = inputs.crane.lib.${system};
in craneLib.buildPackage {
  src = craneLib.cleanCargoSource (craneLib.path ./.);
  strictDeps = true;
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ openssl sqlite ];
}
