#!/usr/bin/env bash
set -euo pipefail
tmpfile=/tmp/nixpkgs-branches-page

# This script checks for any NixOS flake channel updates, and can automatically
# modify the "nixpkgs.url" line in flake.nix to use the latest channel.
# Written by Kaizen86 for Aghostbehindu


# Check if this script has been run recently to warn against polling GitHub's API
if [ -e "$tmpfile" ]; then
  # File exists, but boot.tmp.cleanOnBoot is false by default, so also check modification time
  last_run=$(stat -c %Y "$tmpfile") # Last modification since Epoch
  now=$(date +%s) # Current Epoch
  if [ $((now-last_run)) -lt 3600 ]; then # cooldown is 1 hour
    echo "This script has recently been run. Be careful not to get rate-limited..."
	echo "Channel updates only happen every 6 months. You may want './rebuild.sh -u' instead."
    sleep 4
  fi
fi

gh_api_nixpkgs_branches() {
  # Gets information in JSON about remote Nixpkgs branches on GitHub
  # Usage: gh_api_nixpkgs_branches [url_parameters]
  # Example gh_api_nixpkgs_branches "?page=1&per_page=5"

  local curl_args="" url_params=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -*) curl_args+="$1 " ;;
      *)  url_params="$1"  ;;
    esac
    shift
  done

  curl -s $curl_args \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/nixos/nixpkgs/branches$url_params" 2>&1
  return $?
}

# Genius code from https://kymidd.medium.com/lets-do-devops-get-all-github-repo-branches-even-if-there-s-thousands-482c0e299ab4
# Slightly modified to work in 2026
count_nixpkgs_branches() {
  local response err
  set +e; response=$(gh_api_nixpkgs_branches -vvv "?per_page=1"); err=$?; set -e
  if [ $err -ne 0 ]; then
    # Empty stdout means an error
    # Therefore, echo to stderr
    echo "Error counting nixpkgs branches! ($err)" >&2
    exit 1
  fi

  # Pluck the number of branches from a hyperlink, very clever!
  grep <<<"$response" -F 'header: link: <https://' | rev | cut -d'>' -f2 | cut -d'=' -f 1 | rev
}

query_nixos_branches() {
  [ -e "$tmpfile" ] && rm "$tmpfile"
  # Download all branch pages
  echo -n "Querying nixpkgs branches." >&2
  local page
  for page in $(seq 1 $((1+$(count_nixpkgs_branches)/100))); do
    echo -n . >&2

    local err
    set +e; gh_api_nixpkgs_branches -L "?per_page=100&page=$page" >> $tmpfile; err=$?; set -e
    if [ $err -ne 0 ]; then
      echo -e "\nError querying nixpkgs branches! ($err)" >&2
      exit 1
    fi

    sleep 0.5 # Don't flood the server
  done

  # Filter to just nixos channels and extract the branch names using jq
  echo -n . >&2
  local err
  set +e; nix-shell -p jq --command "jq -rs <$tmpfile 'add | map(.name)[] | match(\"^nixos-.*\").string'"; err=$?; set -e
  if [ $err -ne 0 ]; then
    # Note: jq error message emits newline character; no need to use \n here
    echo "Error parsing GitHub API response! ($err)" >&2
    exit 1
  fi
  # $tmpfile is not deleted so we can tell if there has been a recent API request
  echo >&2
}

function get_channel_version_number() {
  # Gets the version number from some branch name in nixpkgs and stores the major/minor numbers in an array declared by the caller.
  # Usage: get_channel_version_number <$branch> <output_array>

  local _IFS_TMP="$IFS"
  IFS='-'
  local _words=($1)
  IFS="$_IFS_TMP"

  local _field
  for _field in ${_words[@]} _end; do
    if [[ $_field =~ ^[0-9]{2}\.[0-9]{2}$ ]]; then
      break
    fi
  done

  local -a _version_numbers
  if [ $_field != _end ]; then
    # Create array, splitting by '.'
    # Leave empty if loop did not break
	_version_numbers=(${_field/./ })
  fi

  # Copy to globally-declared array, named in $2
  local _out_array_name=$2
  eval "$_out_array_name=(${_version_numbers[@]})"
}

function read_flake_locked_channel() {
  local err
  set +e; nix-shell -p jq --command "jq -r <flake.lock .nodes.nixpkgs.original.ref"; err=$?; set -e
  if [ $err -ne 0 ]; then
    # Note: jq error message emits newline character; no need to use \n here
    echo "Error reading nixpkgs channel from flake.lock! ($err)" >&2
    exit 1
  fi

}

function compare_channel_versions() {
  # Accepts 2 arrays, each representing a channel version (created by get_channel_version_number) and compares if $1 is *greater or equal* to $2.
  # If it is, stdout will be "true", else "false"
  local x_name=$1[@] y_name=$2[@]
  local x=("${!x_name}") y=("${!y_name}")

  local i a b
  local len="${#x[@]}"
  # Compare each version number from left to right
  for i in $(seq 0 $((len-1))); do
    a="${x[i]}"; b="${y[i]}"
    if [ "$a" -lt "$b" ]; then
      echo false; return
    elif [ "$a" -gt "$b" ]; then
      echo true; return
    fi
  done
  # Not less or greater; must be equal
  echo true
}

function get_channel_variant() {
  # e.g 'nixos-12.34-small' variant is 'small', while 'nixos-12.34' has no variant
  local regex='-([a-z0-9]+)$'
  if [[ $1 =~ $regex ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

# Main logic
flake_ref=$(read_flake_locked_channel)
declare -a current_version
get_channel_version_number $flake_ref current_version
# If channel does not list a version number, it might be "nixos-unstable" or similar
if [ ${#current_version[@]} -eq 0 ]; then
  echo "Error while getting current version number; '$flake_ref' does not appear to have a number." >&2
  exit 1
fi
# Detect if it ends with "-small" or similar
flake_ref_variant="$(get_channel_variant $flake_ref)"

latest_channel=0.0 # Initialise to 0
remote_branches="$(query_nixos_branches)"
echo Compatible branches on remote:
for branch in $remote_branches; do
  #echo $branch # Uncomment to print ALL the remote branches
  # Only compare similar variants, e.g don't try going from nixos-XX.XX to nixos-YY.YY-small
  branch_variant=$(get_channel_variant $branch)
  [[ "$branch_variant" != "$flake_ref_variant" ]] && continue
  echo -e "\t$branch" # Only show branches we're checking for upgrades

  declare -a branch_version
  get_channel_version_number $branch branch_version
  # Skip branch if there's no version number
  [ ${#branch_version[@]} -eq 0 ] && continue

  is_gt_or_eq=$(compare_channel_versions branch_version current_version)
  [ $is_gt_or_eq == "true" ] && latest_channel=$branch
done

# Sanity check
if [ $latest_channel == 0.0 ]; then
  echo "... No compatible branches found? Something has gone wrong." >&2
  echo "(flake_ref='$flake_ref', flake_ref_variant='$flake_ref_variant', last remote branch checked is '$branch')" >&2
  exit 1
fi

# No action needed
if [ $flake_ref == $latest_channel ]; then
  echo "You are using the latest stable channel :)"
  exit 0
fi

# Ask if automatic upgrade should be attempted
echo "Neat, there's a new NixOS channel available!"
echo "$flake_ref --> $latest_channel"

# https://stackoverflow.com/a/226724
set -- $(locale LC_MESSAGES)
yesexpr="$1"; noexpr="$2"; yesword="$3"; noword="$4"
while true; do
    read -p "Update flake.nix (${yesword} / ${noword})? " yn
    if [[ "$yn" =~ $yesexpr ]]; then break; fi
    if [[ "$yn" =~ $noexpr ]]; then exit 1; fi
    echo "Answer ${yesword} / ${noword}."
done


regex='(nixpkgs\.url\s*=\s*".*nixpkgs\/)'$flake_ref'(".*)/\1'$latest_channel'\2'
echo $regex
set +e; nix-shell -p gnused --command "sed -E --in-place 's/$regex/m' flake.nix"; err=$?; set -e
if [ $err -ne 0 ]; then
  # Empty stdout means an error
  # Therefore, echo to stderr
  echo "Error encountered while modifying flake.nix! ($err)" >&2
  exit 1
fi

echo -e "Summary of changes:\n"
git diff flake.nix

echo -e '\nTo undo these changes, run "git restore flake.nix"'
echo 'Or run "./rebuild.sh --upgrade" to use the new version!'
echo Be prepared to fix any breaking changes in your config.
