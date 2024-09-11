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
        inputsFrom = [ self.packages.${pkgs.system}.default ];
        packages = [
          pkgs.cargo-bloat
          pkgs.cargo-edit
          pkgs.cargo-outdated
          pkgs.cargo-udeps
          pkgs.cargo-watch
          pkgs.rust-analyzer
          pkgs.clippy
        ];

        env = {
          RUST_BACKTRACE = "1";
        };

        shellHook = ''
          echo "shell pour wordle"
        '';
      };

      packages = {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = "wordle-yvaniak";
          version = "0.1.0";

          nativeBuildInputs = [ pkgs.rustc pkgs.cargo ];

          src = ./.;

          cargoHash = "sha256-w0fwlAcHwGGyoL3UEPPux6uglOLabj5orFXP3EAV2zI=";

          meta = with pkgs.stdenv.lib; {
            description = "A simple wordle tui and gui";
            homepage = "https://github.com/Yvaniak/wordle-yvaniak";
            licence = licences.MIT;
            mainteners = [ mainteners.yvaniak ];
          };
        };

        wordle-yvaniak= self.packages.${pkgs.system}.default;
      };
    }
  );
}
