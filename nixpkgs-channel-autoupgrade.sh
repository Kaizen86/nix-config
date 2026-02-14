#!/usr/bin/env bash
set -euo pipefail
tmpfile=/tmp/nixpkgs-branches

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
  echo 289
  return

  local response err
  set +e; response=$(gh_api_nixpkgs_branches -vvv "?per_page=1"); err=$?; set -e
  if [ $err -ne 0 ]; then
    # Empty stdout means an error
    # Therefore, echo to stderr
    echo "Error counting nixpkgs branches! ($err)" >&2
    return
  fi

  # Pluck the number of branches from a hyperlink, very clever!
  grep <<<"$response" -F 'header: link: <https://' | rev | cut -d'>' -f2 | cut -d'=' -f 1 | rev
}

query_nixpkgs_branches() {
  [ -e "$tmpfile" ] && rm "$tmpfile"
  # Download all branch pages
  echo -n "Querying nixpkgs branches" >&2
  local page
  for page in $(seq 1 $((1+$(count_nixpkgs_branches)/100))); do
    echo -n . >&2

    local err
    set +e; gh_api_nixpkgs_branches -L "?per_page=100&page=$page" >> $tmpfile; err=$?; set -e
    if [ $err -ne 0 ]; then
      echo -e "\nError querying nixpkgs branches! ($err)" >&2
      return
    fi

    sleep 0.5
  done

  # Filter to just nixos channels and extract the branch names using jq
  echo -n . >&2
  local err
  set +e; nix-shell -p jq --command "jq -rs <$tmpfile 'add | map(.name)[] | match(\"^nixos-.*\").string'"; err=$?; set -e
  if [ $err -ne 0 ]; then
    # Note: jq error message emits newline character; no need to use \n here
    echo "Error parsing GitHub API response! ($err)" >&2
  fi
  rm $tmpfile
  echo >&2
}

function extract_channel_version_number() {
  # Gets the version number from some branch name in nixpkgs and stores the major/minor numbers in an array declared by the caller.
  # Usage: extract_channel_version_number <$branch> <output_array>

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
  fi
  
}

#for branch in $(query_nixpkgs_branches); do
for branch in $(<branches.txt); do
  echo $branch

  declare -a version
  extract_channel_version_number $branch version
  for i in ${version[@]}; do
    echo $i
  done
done


