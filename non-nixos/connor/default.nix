{ lib, customLib, ... }:

let
  files = customLib.fs.listFilesExcluding ./. [ "default.nix" ];

in
  {
    # TODO: this would be helpful to have in customLib
    imports = builtins.filter
      (path:
        builtins.match
          ".*\.nix$"
          (builtins.baseNameOf path)
        != null
      )
      files;
  }
