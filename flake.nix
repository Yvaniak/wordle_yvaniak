{
description = "wordle-yvaniak";

inputs = {
  flake-utils = {
    url = "github:numtide/flake-utils";
  };
};

outputs = { self, nixpkgs, ... }@inputs:
  inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      formatter.pkgs = pkgs.nixpkgs-fmt;

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.cargo
          pkgs.rustc
          pkgs.cargo-bloat
          pkgs.cargo-edit
          pkgs.cargo-outdated
          pkgs.cargo-udeps
          pkgs.cargo-watch
          pkgs.rust-analyzer
          pkgs.clippy
          pkgs.rustfmt
        ];

        env = {
          RUST_BACKTRACE = "1";
        };

        shellHook = ''
          echo "shell pour wordle"
        '';
      };
    }
  );
}
