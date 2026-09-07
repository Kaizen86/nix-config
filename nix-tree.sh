#!/usr/bin/env bash
set -eu

if [ "$USER" == "nix-on-droid" ]; then
  flake=".#nixOnDroidConfigurations.connor.config.environment.path"
else
  flake=".#nixOnDroidConfigurations.$(hostname).config.system.build.toplevel"
fi

nix build --print-out-paths --no-link $flake
nix run github:utdemir/nix-tree -- $flake

