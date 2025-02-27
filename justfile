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

pre-commit-all:
  pre-commit run --all-files


docs:
  cargo doc

build-release:
  cargo build --release

all: build tests docs pre-commit-all build-release

