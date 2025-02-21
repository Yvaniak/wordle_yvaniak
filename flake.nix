{
  description = "wordle game in rust for learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nci = {
      url = "github:yusdacra/nix-cargo-integration";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenvs = {
      url = "github:yvaniak/devenvs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    # Adapted From: https://github.com/divnix/digga/blob/main/examples/devos/flake.nix#L4
    extra-substituters = "https://wordleyvaniak.cachix.org https://devenv.cachix.org";
    extra-trusted-public-keys = "wordleyvaniak.cachix.org-1:QIy4s3r5dMLpeOfDcu9YSdlXd14tYcYs/VM1npRMJ8M= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
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
              tools.just.enable = true;
              tools.just.pre-commit.enable = true;
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
