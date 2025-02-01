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
        packages = {

          default = wordle_yvaniak;

          wordle_yvaniak = self.packages.${pkgs.system}.default;
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

      }
    );
}
