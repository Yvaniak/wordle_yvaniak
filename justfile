#this justfile is generated

default:
  just --list

build:
  cargo build

run: build
  cargo run

tests: build
  cargo nextest run
  cargo test --doc
  nix build

pre-commit-all:
  pre-commit run --all-files


docs:
  cargo doc

all: build tests docs pre-commit-all

