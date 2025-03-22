#!/run/current-system/sw/bin/bash
# 

# Find where this script is stored
config_root=$(dirname "$0")

# Read what host configuration this machine should use
if [ -f $config_root/.host_id ]; then
  host_id=$(< $config_root/.host_id)
fi
# Check if the variable is empty
if [ -z $host_id ]; then
  echo .host_id is missing or empty! It should contain one of the following:
  ls $config_root/hosts
  exit 1
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
      nix flake update
      sudo nix-channel --update
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

# Rebuild the system and pass any additional arguments
if [ "$rebuild_args" ]; then
  echo Rebuilding with options: $rebuild_args
fi
rebuild_cmd=sudo nixos-rebuild switch --flake $config_root#$host_id $rebuild_args
echo $rebuild_cmd
$rebuild_cmd; return_code=$?

# Only files tracked by Git will be added to the Nix store, which nixos-rebuild uses to read the config. Therefore, files not tracked by Git will appear to be invisible. Show a warning if git status reports untracked files.
if git status | grep -q "Untracked files:"; then
  echo -e "\nHeads up: some files are untracked by Git. This may cause problems if they're important."
fi

exit $return_code
