{ pkgs, ... }:

{
  languages.rust.enable = true;

  git-hooks.hooks = {
    rustfmt.enable = true;
    taplo.enable = true;
    markdownlint.enable = true;
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

    pkgs.nil
  ];

  env = {
    RUST_BACKTRACE = "1";
  };

  enterShell = ''
    echo "shell pour wordle"
  '';
}
