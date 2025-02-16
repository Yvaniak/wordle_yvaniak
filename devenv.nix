{
  inputs,
  ...
}:

{
  imports = [
    inputs.devenvs.devenvModules.devenvs.default
  ];
  rust.enable = true;
  nix.enable = true;

  enterShell = ''
    echo "shell pour wordle"
  '';
}
