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

        mylib = {
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
              cargo fix
            '';
          };
          update = pkgs.writeShellApplication {
            name = "update";
            text = ''
              cargo update
            '';
          };
          install_deps = pkgs.writeShellApplication {
            name = "install_deps";
            text = ''
              cargo fetch
            '';
          };
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
            mylib.fmt
            mylib.lint
            mylib.update
            mylib.install_deps
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
            doUnpack = false;

            doCheck = true; #pas sûr que ce soit faux par défaut mais on sait jamais

            meta = {
              homepage = "https://github.com/Yvaniak/wordle-yvaniak";
              licence = pkgs.stdenv.lib.licences.MIT;
            };
          };

          wordle-yvaniak = self.packages.${pkgs.system}.default;

          docker = pkgs.dockerTools.buildLayeredImage {
            name = "wordle-yvaniak";
            tag = "latest";
            config.Cmd = [ "${self.packages.${pkgs.system}.default}/bin/wordle-yvaniak" ];
          };


        };
      }
    );
}
