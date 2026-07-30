{
  description = "set-me-up Home Manager blueprint example";

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [
        ./generated/home-manager/default.nix
      ];
    };
  };
}
