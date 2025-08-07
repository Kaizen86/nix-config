#!/usr/bin/env bash
nix build --print-out-paths --no-link .#nixosConfigurations.$(hostname).config.system.build.toplevel
nix run github:utdemir/nix-tree -- .#nixosConfigurations.$(hostname).config.system.build.toplevel

