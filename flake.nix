{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    pre-commit-hooks,
    ...
  } @ inputs: let
  in
    utils.lib.eachDefaultSystem (system: let
      overlay = final: prev: {
        nix-pulumi.lib = {
          mkPulumiProject = import ./lib/mkPulumiProject.nix {inherit (final) pkgs;};
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay];
      };
    in {
      lib = pkgs.nix-pulumi.lib;

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
          };
        };
      };
    });
}
