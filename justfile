tests:
  pre-commit run --all-files
  cargo nextest run
  cargo test --doc
  nix build

docs:
  cargo doc

