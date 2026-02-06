{ lib, customLib, ... }:

let
  files = customLib.fs.listFilesExcluding ./. [ "default.nix" ];

in
  {
    imports = builtins.filter
      (path:
        builtins.match
          ".*\.nix$"
          (builtins.baseNameOf path)
        != null
      )
      files;
  }
