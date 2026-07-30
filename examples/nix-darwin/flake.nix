{
  description = "set-me-up nix-darwin blueprint example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nix-darwin, ... }: {
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./generated/nix-darwin/default.nix
      ];
    };
  };
}
