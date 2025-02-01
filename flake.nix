{
  description = "wordle_yvaniak";

  nixConfig = {
    # Adapted From: https://github.com/divnix/digga/blob/main/examples/devos/flake.nix#L4
    extra-substituters = "https://wordleyvaniak.cachix.org https://devenv.cachix.org";
    extra-trusted-public-keys = "wordleyvaniak.cachix.org-1:QIy4s3r5dMLpeOfDcu9YSdlXd14tYcYs/VM1npRMJ8M= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-experimental-features = "nix-command flakes";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane.url = "github:ipetkov/crane";

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      advisory-db,
      ...
    }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        craneLib = inputs.crane.mkLib pkgs;
        src = ./.;

        # Build *just* the cargo dependencies, so we can reuse
        # all of that work (e.g. via cachix) when running in CI
        cargoArtifacts = craneLib.buildDepsOnly {
          inherit src;
        };

        wordle_yvaniak-cargo-audit = craneLib.cargoAudit {
          inherit src advisory-db;
        };

        wordle_yvaniak-cargo-doc = craneLib.cargoDoc {
          inherit cargoArtifacts src;
        };

        wordle_yvaniak-cargo-doc-test = craneLib.cargoDocTest {
          inherit cargoArtifacts src;
        };

        wordle_yvaniak-cargo-deny = craneLib.cargoDeny {
          inherit src;
        };

        wordle_yvaniak-cargo-nextest = craneLib.cargoNextest {
          inherit cargoArtifacts src;
        };

        wordle_yvaniak-cargo-update = craneLib.buildPackage {
          inherit cargoArtifacts src;
          cargoBuildCommand = "cargo update --recursive && cargo build --profile release";
          pnameSuffix = "-cargo-update";
        };

        wordle_yvaniak-cargo-outdated = craneLib.mkCargoDerivation {
          buildInputs = [ pkgs.cargo-outdated ];
          inherit cargoArtifacts src;
          buildPhaseCargoCommand = "cargo outdated --exit-code 100";
          pnameSuffix = "-cargo-outdated";
        };

        wordle_yvaniak-cargo-machete = craneLib.mkCargoDerivation {
          buildInputs = [ pkgs.cargo-machete ];
          inherit cargoArtifacts src;
          buildPhaseCargoCommand = "cargo machete";
          pnameSuffix = "-cargo-machete";
        };

        # Build the actual crate itself, reusing the dependency
        # artifacts from above.
        wordle_yvaniak = craneLib.buildPackage {
          inherit cargoArtifacts src;
          meta = {
            homepage = "https://github.com/Yvaniak/wordle_yvaniak";
            licence = pkgs.stdenv.lib.licences.MIT;
          };
        };

        # Also run the crate tests under cargo-tarpaulin so that we can keep
        # track of code coverage
        wordle_yvaniak-coverage = craneLib.cargoTarpaulin {
          inherit cargoArtifacts src;
          cargoTarpaulinExtraArgs = "--skip-clean --out Html --output-dir $out";
          CARGO_PROFILE = "";
        };
      in
      {
        devShells.default = inputs.devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            (
              { pkgs, ... }:
              {
                languages.rust.enable = true;

                git-hooks.hooks = {
                  rustfmt.enable = true;
                  taplo.enable = true;
                  markdownlint.enable = true;
                  yamlfmt.enable = true;
                  clippy.enable = true;
                  cargo-check.enable = true;

                  nixfmt-rfc-style.enable = true;
                  statix.enable = true;
                  deadnix.enable = true;
                  commitizen.enable = true;
                };

                packages = [
                  #voir la taille des grosses deps
                  pkgs.cargo-bloat
                  #gerer les deps depuis le cli
                  pkgs.cargo-edit
                  #auto compile
                  pkgs.cargo-watch
                ];

                env = {
                  RUST_BACKTRACE = "1";
                };

                enterShell = ''
                  echo "shell pour wordle"
                '';
              }
            )
          ];
        };

        packages = {

          default = wordle_yvaniak;

          wordle_yvaniak = self.packages.${pkgs.system}.default;

          devenv-up = self.devShells.${system}.default.config.procfileScript;
          devenv-test = self.devShells.${system}.default.config.test;
        };

        checks = {
          inherit
            wordle_yvaniak
            wordle_yvaniak-cargo-audit
            wordle_yvaniak-coverage
            wordle_yvaniak-cargo-deny
            wordle_yvaniak-cargo-doc
            wordle_yvaniak-cargo-doc-test
            wordle_yvaniak-cargo-nextest
            wordle_yvaniak-cargo-update
            wordle_yvaniak-cargo-outdated
            wordle_yvaniak-cargo-machete
            ;
        };

        # githubActions = inputs.nix-github-actions.lib.mkGithubMatrix { checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] self.checks; };
      }
    )
    // inputs.flake-utils.lib.eachDefaultSystemPassThrough (_: {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] self.checks;
      };
    });
}
