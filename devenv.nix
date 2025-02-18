{
  inputs,
  ...
}:

{
  imports = [
    inputs.devenvs.devenvModules.devenvs.default
  ];
  rust.enable = true;
  rust.tests.enable = true;
  nix.enable = true;
  nix.flake.enable = true;

  enterShell = ''
    echo "shell pour wordle"
  '';
}
