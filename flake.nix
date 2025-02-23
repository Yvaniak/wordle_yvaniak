{
  description = "wordle game in rust for learning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenvs = {
      url = "github:yvaniak/devenvs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-flake = {
      url = "github:juspay/rust-flake";
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
        inputs.devenvs.flakeModules.default
        inputs.devenvs.devenv
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          ...
        }:
        {
          packages.default = config.packages.wordle_yvaniak;
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
