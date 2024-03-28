{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.war-room = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
