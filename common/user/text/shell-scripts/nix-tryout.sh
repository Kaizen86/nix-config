set -eu
# Often I want to try out a program by installing it ephemerally.
# This function immediately starts the program with arguments after it finishes downloading.
# Optionally allows specifying a different command name by passing -- first

# First argument is always package to use
if [ $# -lt 1 ]; then
	echo No package specified
	exit 1
fi
package="$1"
shift

# Parse next argument
if [[ $# -gt 0 && "$1" == "--" ]]; then
	shift
	command="$1"
	shift
else
	command="$package"
fi
args="$@"

# Check if this package is unfree
unfree=$(nix-instantiate --eval --expr "(import <nixpkgs> {}).$package.meta.unfree")
# Set magic environment variable if necessary
if [ $unfree == true ]; then
	echo This package is unfree, setting NIXPKGS_ALLOW_UNFREE=1 and proceeding...
	export NIXPKGS_ALLOW_UNFREE=1
fi

# Run it
nix shell --impure nixpkgs#$package --command $command $args
exit $?

