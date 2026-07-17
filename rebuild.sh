#!/usr/bin/env bash
# Updates the system according to this nix configuration.
set -eo pipefail

# If shit hits the breeze blender, here's how to reinstall the bootloader from a live usb!
# mount /dev/sdXY /mnt
# mount /dev/sdXZ /mnt/boot
# nixos-install --root /mnt --no-root-password --flake /mnt/home/kaizen/nix-config#laptop

# Find where this script is stored
config_root=$(dirname "$0")
rebuild_cmd=switch

function show_help() {
  script_name=$(basename "$0")
  cat <<EOF
Usage: $script_name [-uh] [args] [command]
Wrapper around \`nixos-rebuild\` with extra functionality.
Options:
  -u --upgrade --update
    Runs \`nix flake update\` first. Implies \`boot\` command.
  -h --help
    Show this help text.

Any other arguments are passed to nixos-rebuild.
This script also passes which command to use for nixos-rebuild.
Here's a non-definitive list of commands:
  switch: build+activate+add GRUB menuentry (default)
  test: build+activate but do not add GRUB menuentry
  boot: build then activate on next boot (good for system upgrades)
  repl: build and enter REPL for debugging

Read the nixos-rebuild documentation for a definitive list of rebuild arguments and commands.
EOF
}

function readback() {
  cmd=$*
  # If running as root, strip any use of sudo.
  # sudo doesn't work if PAM authentication is offline, such as
  # when nixos-enter is used from the live installer to recover the system.
  if [ $(id -u) -eq 0 ]; then
    echo disabling sudo
    cmd=$(sed 's/^\s*sudo\s+//' <<< $cmd)
  fi

  # Echo command before running it
  echo $cmd
  $cmd
  return $?
}

# Parse any command-line options
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit
      ;;
    -u|--upgrade|--update)
      readback nix flake update
      rebuild_cmd=boot # Don't switch immediately
      ;;
    -*)
      rebuild_args+=" $1"
      ;;
    *)
      rebuild_cmd="$1"
      ;;
  esac
  shift
done

# Only files tracked by Git will be added to the Nix store, which nixos-rebuild uses to read the config.
# Therefore, files not tracked by Git will appear to be invisible.
# Show a warning if git status reports untracked files.
pushd "$config_root" > /dev/null
if git status | grep -q "Untracked files:"; then
  echo -e "Heads up: some files are untracked by Git. This may cause problems if they're important.\n"
fi
popd > /dev/null

# Nix On Droid is a special case
if [ "$USER" == "nix-on-droid" ]; then
  # nixos-rebuild won't work on this host
  echo Using nix-on-droid specific command
  time readback nix-on-droid switch --flake "$config_root#connor" $rebuild_args
  exit $?
fi

# Check if hostname not in hosts folder
# This will require intervention - the flake won't know which target to build
# Usually this happens when setting up a new system as the hostname will be 'nixos'
if [ ! -d "$config_root/hosts/$(hostname)" ]; then
  echo Warning! The hostname does not exist as a folder in 'hosts' directory.
  echo Assuming this is a new system and you\'re following the README
  echo to set it up, please specify which flake attribute to use.
  echo Make sure it sets the system hostname to the folder name so this persists!
  select attribute in $(ls "$config_root/hosts"); do
    if [ -z "$attribute" ]; then
      # Invalid number
      echo Aborting.
      exit 1
    fi
    attribute=\#$attribute # flake attributes start with a hash
    break # Variable has been set; exit menu
  done
else
  # Otherwise, make sure the variable is empty
  unset attribute
fi

# Rebuild the system and pass any additional arguments
time readback sudo nixos-rebuild $rebuild_cmd --flake "$config_root$attribute" $rebuild_args
rebuild_exit=$?

if [ $rebuild_cmd == "boot" ]; then
  echo System will use new configuration on reboot!
fi

exit $rebuild_exit

