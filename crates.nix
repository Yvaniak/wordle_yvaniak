_: {
  perSystem =
    _:
    let
      crateName = "wordle_yvaniak";
    in
    {
      # declare projects
      nci.projects.${crateName}.path = ./.;
      # configure crates
      nci.crates.${crateName} = { };
    };
}
