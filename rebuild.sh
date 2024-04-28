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
      echo "${FUNCNAME[0]}: unrecognised option '$1'
Try '${FUNCNAME[0]} --help' for more information"
      exit 1
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
echo sudo nixos-rebuild switch --flake /home/kaizen/nix-config#$host_id $rebuild_args
sudo nixos-rebuild switch --flake /home/kaizen/nix-config#$host_id $rebuild_args

# For reasons I do not yet understand, nixos-rebuild needs .nix files to be tracked by Git, otherwise they will seem invisible.
if git status | grep -q "Untracked files:"; then
  echo -e "\nHeads up: some files are untracked by Git. This may cause you problems if they're important."
fi
