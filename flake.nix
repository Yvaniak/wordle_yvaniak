{
  description = "wordle-yvaniak";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        naersk' = pkgs.callPackage inputs.naersk { };

        fmt = pkgs.writeShellApplication {
          name = "fmt";
          text = ''
            nixpkgs-fmt .
            cargo fmt
          '';
        };
        lint = pkgs.writeShellApplication {
          name = "lint";
          text = ''
            cargo clippy
          '';
        };
      in
      {
        formatter.pkgs = pkgs.nixpkgs-fmt;

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

            #scripts utilitaires
            fmt
            lint
          ];

          env = {
            RUST_BACKTRACE = "1";
          };

          shellHook = ''
            echo "shell pour wordle"
          '';
        };

        packages = {
          default = naersk'.buildPackage {
            nativeBuildInputs = [ pkgs.rustc pkgs.cargo ];

            src = ./.;

            doCheck = true; #pas sûr que ce soit faut par défaut mais on sait jamais

            meta = with pkgs.stdenv.lib; {
              homepage = "https://github.com/Yvaniak/wordle-yvaniak";
              licence = licences.MIT;
              mainteners = [ mainteners.yvaniak ];
            };
          };

          wordle-yvaniak = self.packages.${pkgs.system}.default;
        };
      }
    );
}
