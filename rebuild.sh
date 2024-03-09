#!/run/current-system/sw/bin/bash
# 

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

# Rebuild the system
sudo nixos-rebuild switch --flake /home/kaizen/nix-config#$host_id

