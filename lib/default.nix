{ lib }:

let
  namespaces = {
    fs = ./filesystem.nix;
    attrsets = ./attrsets.nix;
  };

  # This is where the self-referential magic lives
  customLib = lib.mapAttrs
    (ns: file: import file { inherit lib customLib; })
    namespaces;

in customLib

