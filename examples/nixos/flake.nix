{
  description = "set-me-up NixOS blueprint example";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./generated/nixos/server.nix
      ];
    };
  };
}
