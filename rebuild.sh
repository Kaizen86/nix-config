#!/usr/bin/env bash
# Updates the system according to this nix configuration.

# Find where this script is stored
config_root=$(dirname "$0")

readback() {
  # Echo command before running it
  echo $*
  $*
  return $?
}

if [ "$USER" == "nix-on-droid" ]; then
  # Usual nixos-rebuild and nix-channel commands won't work on this host
  echo Using nix-on-droid specific command
  readback nix-on-droid switch --flake $config_root#connor
  exit $?
fi

# Parse any command-line options
while [ "$1" ]; do
  case "$1" in
    --help)
      # todo add help text
      echo "$0"
      exit
      ;;
    -u|--upgrade)
      readback nix flake update
      readback sudo nix-channel --update
      #nix-env -u
      #rebuild_args="$rebuild_args -I $HOME/nix-config"
      rebuild_args="$rebuild_args --upgrade"
      shift
      ;;
    -*)
      rebuild_args="$rebuild_args $1"
      ;;
    *)
      echo "Ignoring argument '$1'"
      shift
      ;;
  esac
done

# Check if hostname not in hosts folder
# This will require intervention - the flake won't know which target to build
# Usually this happens when setting up a new system as the hostname will be 'nixos'
if [ ! -d hosts/$(hostname) ]; then
  echo Warning! The hostname does not exist as a folder inside hosts/
  echo Assuming this is a new system and you\'re following the README
  echo to set it up, please specify which flake attribute to use.
  echo First make sure the attribute sets the system hostname to the folder name!
  select attribute in $(ls hosts); do
    if [ -z "$attribute" ]; then
      # Invalid number
      echo Aborting.
      exit 1
    fi
    attribute=\#$attribute # prepend hash (e.g foo -> #foo)
    break # Variable has been set; exit menu
  done
else
  # Otherwise, make sure the variable is empty
  unset attribute
fi

# Rebuild the system and pass any additional arguments
if [ "$rebuild_args" ]; then
  echo Rebuilding with options: $rebuild_args
fi
readback sudo nixos-rebuild switch --flake $config_root$attribute $rebuild_args
return_code=$?

# Only files tracked by Git will be added to the Nix store, which nixos-rebuild uses to read the config.
# #Therefore, files not tracked by Git will appear to be invisible.
# Show a warning if git status reports untracked files.
if git status | grep -q "Untracked files:"; then
  echo -e "\nHeads up: some files are untracked by Git. This may cause problems if they're important."
fi

exit $return_code
