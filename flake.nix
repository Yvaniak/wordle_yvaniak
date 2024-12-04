{
  description = "wordle_yvaniak";

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
  };

  outputs = { self, nixpkgs, advisory-db, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem
      (system:
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

          # Run clippy (and deny all warnings) on the crate source,
          # resuing the dependency artifacts (e.g. from build scripts or
          # proc-macros) from above.
          #
          # Note that this is done as a separate derivation so it
          # does not impact building just the crate by itself.
          wordle_yvaniak-clippy = craneLib.cargoClippy {
            inherit cargoArtifacts src;
            cargoClippyExtraArgs = "-- --deny warnings";
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

          wordle_yvaniak-cargo-fmt = craneLib.cargoFmt {
            inherit src;
          };

          wordle_yvaniak-taplo-fmt = craneLib.taploFmt {
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

          wordle_yvaniak-cargo-check = craneLib.buildPackage {
            inherit cargoArtifacts src;
            cargoBuildCommand = "cargo check";
            pnameSuffix = "-cargo-check";
          };

          wordle_yvaniak-cargo-check-release = craneLib.buildPackage {
            inherit cargoArtifacts src;
            cargoBuildCommand = "cargo check --release";
            pnameSuffix = "-cargo-check-release";
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
          formatter = pkgs.nixpkgs-fmt;

          devShells.default = pkgs.mkShell {
            inputsFrom = [ 
              self.packages.${pkgs.system}.default
              self.checks.${system}.wordle_yvaniak-clippy
              self.checks.${system}.wordle_yvaniak-cargo-audit
              self.checks.${system}.wordle_yvaniak-coverage
              self.checks.${system}.wordle_yvaniak-cargo-deny
              self.checks.${system}.wordle_yvaniak-cargo-doc
              self.checks.${system}.wordle_yvaniak-cargo-doc-test
              self.checks.${system}.wordle_yvaniak-cargo-fmt
              self.checks.${system}.wordle_yvaniak-cargo-nextest
              self.checks.${system}.wordle_yvaniak-cargo-update
              self.checks.${system}.wordle_yvaniak-cargo-outdated
              self.checks.${system}.wordle_yvaniak-cargo-machete
              self.checks.${system}.wordle_yvaniak-cargo-check
              self.checks.${system}.wordle_yvaniak-cargo-check-release
              self.checks.${system}.wordle_yvaniak-taplo-fmt
            ];
            packages = [
              #voir la taille des grosses deps
              pkgs.cargo-bloat
              #gerer les deps depuis le cli
              pkgs.cargo-edit
              #auto compile
              pkgs.cargo-watch
              #lsp
              pkgs.rust-analyzer
            ];

            env = {
              RUST_BACKTRACE = "1";
            };

            shellHook = ''
              echo "shell pour wordle"
            '';
          };

          packages = {

            default = wordle_yvaniak;

            wordle_yvaniak = self.packages.${pkgs.system}.default;
          };

          checks = {
            inherit
              wordle_yvaniak
              wordle_yvaniak-clippy
              wordle_yvaniak-cargo-audit
              wordle_yvaniak-coverage
              wordle_yvaniak-cargo-deny
              wordle_yvaniak-cargo-doc
              wordle_yvaniak-cargo-doc-test
              wordle_yvaniak-cargo-fmt
              wordle_yvaniak-cargo-nextest
              wordle_yvaniak-cargo-update
              wordle_yvaniak-cargo-outdated
              wordle_yvaniak-cargo-machete
              wordle_yvaniak-cargo-check
              wordle_yvaniak-cargo-check-release
              wordle_yvaniak-taplo-fmt;
          };

          # githubActions = inputs.nix-github-actions.lib.mkGithubMatrix { checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] self.checks; };
        }
      )
    // inputs.flake-utils.lib.eachDefaultSystemPassThrough (system: {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix { checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] self.checks; };
    });
}
