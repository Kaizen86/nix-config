#!/usr/bin/env bash
# Launches "nix build" with the --debugger flag to stop at breakpoints or errors.
set -eu

if [ "$USER" == "nix-on-droid" ]; then
  echo Unsupported
  exit 1
fi

debug="nix build --no-link --debugger "$@" .#nixosConfigurations.$(hostname).config.system.build.toplevel"
#(echo ":st" && cat) | sh -c "$debug"

nix-shell -p expect --command "expect -c '
  log_user 0
  spawn $debug
  send :st\r

  log_user 1
  interact'"

