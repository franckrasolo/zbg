set dotenv-load := true

_targets:
  @just --list --unsorted --list-heading $'Available targets:\n' --list-prefix "  "

# updates the top-level flake lock file
@update:
  nix flake update --commit-lock-file --commit-lockfile-summary "update Nix flake inputs"

# builds the executable
@build:
  # opam install . --deps-only --with-doc --with-test
  dune build
  cp -f _build/default/bin/main.exe $XDG_BIN_HOME/zbg

# runs all tests
@check:
  #dune runtest --force --build-info --display=verbose
  dune runtest
