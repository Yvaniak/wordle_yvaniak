{
  description = "wordle game in rust for learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nci.url = "github:yusdacra/nix-cargo-integration";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nci.flakeModule
        ./crates.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          self',
          config,
          ...
        }:
        let
          crateOutputs = config.nci.outputs."wordle_yvaniak";
        in
        {
          packages.wordle_yvaniak = crateOutputs.packages.release;
          packages.default = self'.packages.wordle_yvaniak;
        };
      flake =
        {
        };
    };
}
