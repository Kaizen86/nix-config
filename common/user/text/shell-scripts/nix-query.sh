# Display meta information about a package
package=$1
if [ -z "$package" ]; then
	echo No package specified
	exit 1
fi

nix eval --impure --raw --expr "
	let
	  nixpkgs = import <nixpkgs> {};
	  lib = nixpkgs.lib;
	in
	  lib.generators.toPretty {} nixpkgs.$package.meta"

