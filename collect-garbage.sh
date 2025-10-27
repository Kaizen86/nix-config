#!/usr/bin/env bash
# Delete old systems profiles
set -euo pipefail

# Find where this script is stored
config_root=$(dirname "$0")

readback() {
  cmd=$*
  # If running as root, strip any use of sudo.
  # sudo doesn't work if PAM authentication is offline, such as
  # when nixos-enter is used from the live installer to recover the system.
  if [ $(id -u) -eq 0 ]; then
    echo disabling sudo
    cmd=$(echo $cmd | sed 's/^sudo\s*//')
  fi

  # Echo command before running it
  echo $cmd
  $cmd
  return $?
}

if [ "$USER" == "nix-on-droid" ]; then
  # On Android, 'nix-store --optimise' won't work as creating hard links is forbidden
  echo Using nix-on-droid specific command
  readback nix-collect-garbage -d 
  exit $?
fi

# This took me far too long to figure out, but the command must be run as root, otherwise it can't touch most links
# https://www.reddit.com/r/NixOS/comments/unwip2/deleting_old_system_profiles_what_am_i_missing/

readback sudo nix-collect-garbage -d 
readback sudo nix-store --optimise

