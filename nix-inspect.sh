#!/usr/bin/env bash
set -eu

if [ "$USER" == "nix-on-droid" ]; then
  echo Unsupported
  exit 1
fi

nix run github:bluskript/nix-inspect
