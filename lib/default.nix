{ lib }:

let
  namespaces = {
    fs = ./filesystem.nix;
    attrsets = ./attrsets.nix;
  };

  customLib = lib.mapAttrs
    (ns: file: import file { inherit lib customLib; })
    namespaces;

in customLib

