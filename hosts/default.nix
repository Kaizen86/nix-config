{ inputs, modules, lib, customLib }:
let
  # Automatically discover host folders
  hostDirs = customLib.fs.listDirs ./.;

  mkNixosSystem = (hostDir: {
    name = builtins.baseNameOf hostDir;
    value = lib.nixosSystem {
      specialArgs = { inherit inputs customLib; };
      modules = modules ++ customLib.fs.listNixModulesRecursive hostDir;
    };
  });

in builtins.listToAttrs (map mkNixosSystem hostDirs)

