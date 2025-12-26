#!/usr/bin/env bash
set -eu

if [ "$USER" == "nix-on-droid" ]; then
  echo Unsupported
  exit 1
fi

debug="nix build --debugger .#nixosConfigurations.$(hostname).config.system.build.toplevel"
#(echo ":st" && cat) | sh -c "$debug"

nix-shell -p expect --command "expect -c '
  log_user 0
  spawn $debug
  send :st\r

  log_user 1
  interact'"

