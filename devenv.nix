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
  nix = {
    enable = true;
    flake.enable = true;
    tests.enable = true;
  };

  enterShell = ''
    echo "shell pour wordle"
  '';
}
