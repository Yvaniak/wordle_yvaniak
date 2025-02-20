{
  description = "wordle game in rust for learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nci.url = "github:yusdacra/nix-cargo-integration";
    devenvs.url = "github:yvaniak/devenvs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nci.flakeModule
        ./crates.nix
        inputs.devenvs.flakeModules.default
        inputs.devenvs.devenv
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
          devenv.shells.default = {
            devenvs = {
              rust.enable = true;
              rust.tests.enable = true;
              nix = {
                enable = true;
                flake.enable = true;
                tests.enable = true;
              };
            };

            enterShell = ''
              echo "shell pour wordle"
            '';
          };
        };
      flake = {
      };
    };
}
