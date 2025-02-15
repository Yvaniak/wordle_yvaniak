{ inputs, ... }:

{
  imports = [
    inputs.devenvs.homeManagerModules.devenvs.default
  ];
  rust.enable = true;
  nix.enable = true;

  enterShell = ''
    echo "shell pour wordle"
  '';
}
