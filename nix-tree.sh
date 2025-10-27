#!/usr/bin/env bash
set -eu

if [ "$USER" == "nix-on-droid" ]; then
  echo Unsupported
  exit 1
fi

flake=".#nixosConfigurations.$(hostname).config.system.build.toplevel"
nix build --print-out-paths --no-link $flake
nix run github:utdemir/nix-tree -- $flake

