#!/run/current-system/sw/bin/bash
# Updates the system according to this nix configuration.
# Note: the shebang is for nix-os, use 'bash rebuild.sh' for other platforms. 

# Find where this script is stored
CONFIG_ROOT=$(dirname "$0")

# Read what host configuration this machine should use
if [ -f $CONFIG_ROOT/.host_id ]; then
  host_id=$(< $CONFIG_ROOT/.host_id)
fi
# Check if the variable is empty
if [ -z $host_id ]; then
  echo .host_id is missing or empty! It should contain one of the following:
  ls $CONFIG_ROOT/hosts
  exit 1
fi

# Rebuild the system with the appropriate command
case $host_id in
  connor)
    # nix-on-droid
    nix-on-droid switch --flake ~/nix-config#$host_id
    ;;

  *)
    # standard nix-os
    sudo nixos-rebuild switch --flake ~/nix-config#$host_id
    ;;
esac

