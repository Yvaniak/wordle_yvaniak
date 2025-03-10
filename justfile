#this justfile is generated

# print the just commands
default:
    just --list

alias b := build

# build the software
build:
    cargo build

alias r := run

# run the software
run: build
    cargo run

alias t := tests

# launch all the tests
tests: build
    cargo nextest run
    cargo test --doc

alias p := pre-commit-all

# launch all the pre-commit hooks on all the files
pre-commit-all:
    pre-commit run --all-files

alias d := docs

# build the docs
docs:
    cargo doc

alias br := build-release

# build the software in release mode
build-release:
    cargo build --release

alias nc := nix-checks

# launch all the checks in a flake if present and nix is available
nix-checks:
    if nix --version; then     nix flake check --no-pure-eval --extra-experimental-features flakes --extra-experimental-features nix-command;  else     echo nix is not available, so the nix checks are skipped;   fi

alias a := all

# launch all the steps
all: build tests docs pre-commit-all build-release nix-checks

alias w := watch

# launch all the steps (can be very intense on cpu)
watch:
    watchexec just build tests docs pre-commit-all
