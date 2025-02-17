{
  description = "wordle_yvaniak";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      self,
      nixpkgs,
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

        wordle_yvaniak-cargo-outdated = craneLib.mkCargoDerivation {
          buildInputs = [ pkgs.cargo-outdated ];
          inherit cargoArtifacts src;
          buildPhaseCargoCommand = "cargo outdated --exit-code 100";
          pnameSuffix = "-cargo-outdated";
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
      in
      {
        packages = {

          default = wordle_yvaniak;

          wordle_yvaniak = self.packages.${pkgs.system}.default;
        };

        checks = {
          inherit
            wordle_yvaniak
            wordle_yvaniak-cargo-outdated
            ;
        };

      }
    );
}
