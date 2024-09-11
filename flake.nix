{
description = "wordle-yvaniak";

inputs = {
  nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = { self, nixpkgs, ... }@inputs:
  inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      # overlays = [ (import inputs.rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system; #rajouter overlays pour activer rust-overlay
      };
    in
    {
      formatter.pkgs = pkgs.nixpkgs-fmt;

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cargo
          pkgs.rustc
          #pour overlay pkgs.rustToolchain
          pkgs.cargo-bloat
          pkgs.cargo-edit
          pkgs.cargo-outdated
          pkgs.cargo-udeps
          pkgs.cargo-watch
          pkgs.rust-analyzer
        ];

        env = {
          RUST_BACKTRACE = "1";
          #pour overlay RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
        };

        shellHook = ''
          echo "shell pour wordle"
        '';
      };
    }
  );
}
