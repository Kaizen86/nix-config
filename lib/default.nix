{ nixpkgs }:
let
  lib = nixpkgs.lib;
in
  {
    fs = import ./filesystem.nix { inherit lib; };
  }
