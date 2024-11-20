{
  description = "wordle_yvaniak";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    naersk.url = "github:nix-community/naersk";

    crane.url = "github:ipetkov/crane";

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, advisory-db, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        naersk' = pkgs.callPackage inputs.naersk { };

        craneLib = inputs.crane.mkLib pkgs;
        src = ./.;

        # Build *just* the cargo dependencies, so we can reuse
        # all of that work (e.g. via cachix) when running in CI
        cargoArtifacts = craneLib.buildDepsOnly {
          inherit src;
        };

        crateName = craneLib.crateNameFromCargoToml { cargoToml = ./Cargo.toml; };

        # Run clippy (and deny all warnings) on the crate source,
        # resuing the dependency artifacts (e.g. from build scripts or
        # proc-macros) from above.
        #
        # Note that this is done as a separate derivation so it
        # does not impact building just the crate by itself.
        my-crate-clippy = craneLib.cargoClippy {
          inherit cargoArtifacts src;
          cargoClippyExtraArgs = "-- --deny warnings";
          buildPhaseCargoCommand = "cargo clippy --profile release && cargo fix";
        };

        my-crate-cargo-audit = craneLib.cargoAudit {
          inherit src advisory-db;
        };

        my-crate-cargo-doc = craneLib.cargoDoc {
          inherit cargoArtifacts src;
        };

        my-crate-cargo-doc-test = craneLib.cargoDocTest {
          inherit cargoArtifacts src;
        };

        my-crate-cargo-deny = craneLib.cargoDeny {
          inherit src;
        };

        my-crate-cargo-fmt = craneLib.cargoFmt {
          inherit src;
        };

        my-crate-taplo-fmt = craneLib.taploFmt {
          inherit src;
        };

        my-crate-cargo-llvm-cov = craneLib.cargoLlvmCov {
          inherit cargoArtifacts src;
        };

        my-crate-cargo-nextest = craneLib.cargoNextest {
          inherit cargoArtifacts src;
        };

        my-crane-cargo-update = craneLib.buildPackage {
          inherit cargoArtifacts src;
          cargoBuildCommand = "cargo update && cargo build --profile release";
        };

        # Build the actual crate itself, reusing the dependency
        # artifacts from above.
        my-crate = craneLib.buildPackage {
          inherit cargoArtifacts src;
        };

        # Also run the crate tests under cargo-tarpaulin so that we can keep
        # track of code coverage
        my-crate-coverage = craneLib.cargoTarpaulin {
          inherit cargoArtifacts src;
        };

        mylib = {
          lint = pkgs.writeShellApplication {
            name = "lint";
            text = ''
              cargo clippy
              cargo fix
            '';
          };
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.system}.default ];
          packages = [
            #voir la taille des grosses deps
            pkgs.cargo-bloat
            #gerer les deps depuis le cli
            pkgs.cargo-edit
            #trouver les outdated
            pkgs.cargo-outdated
            #trouver les deps non utilisés (à besoin de nightly)
            pkgs.cargo-udeps
            #auto compile
            pkgs.cargo-watch
            #lsp
            pkgs.rust-analyzer
            #lint
            pkgs.clippy
            #fmt rust
            pkgs.rustfmt
            #fmt nix
            pkgs.nixpkgs-fmt

            #a voir
            pkgs.cargo-audit
            pkgs.cargo-deny

            #scripts utilitaires
            mylib.lint
          ];

          env = {
            RUST_BACKTRACE = "1";
          };

          shellHook = ''
            echo "shell pour wordle"
          '';
        };

        packages = {
          crane-test = my-crate;
          default = naersk'.buildPackage {
            nativeBuildInputs = [ pkgs.rustc pkgs.cargo ];

            src = ./.;
            doUnpack = false;

            doCheck = true; #pas sûr que ce soit faux par défaut mais on sait jamais

            meta = {
              homepage = "https://github.com/Yvaniak/wordle_yvaniak";
              licence = pkgs.stdenv.lib.licences.MIT;
            };
          };

          wordle_yvaniak = self.packages.${pkgs.system}.default;
        };
        
        checks = {
          inherit
            my-crate
            my-crate-clippy
            my-crate-coverage
            my-crate-cargo-audit
            my-crate-cargo-deny
            my-crate-cargo-doc
            my-crate-cargo-doc-test
            my-crate-cargo-fmt
            my-crate-cargo-llvm-cov
            my-crate-cargo-nextest
            my-crate-taplo-fmt
            my-crane-cargo-update;
        };
      }
    );
}
