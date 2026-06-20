{ lib, customLib }:

# TODO: Use asserts to validate function inputs

rec {
  # Straightforward readDir, gives you a plain list of paths
  readDir = (path:
    let
      dirListing = builtins.readDir path;
      itemNames = builtins.attrNames dirListing;
    in
      # Convert names to full path
      map
        (n: lib.path.append path n)
        itemNames
  );

  # Get a list of paths in a directory, filtered by item type (e.g. "regular", "directory", etc).
  readDirByType = (type: path:
    let
      dirListing = builtins.readDir path;
      # Select names where the value matches $type
      matchedItemNames = customLib.attrsets.filterAttrNames
        (n: v: v==type)
        dirListing;
    in
      # Convert names to full path
      map
        (n: lib.path.append path n)
        matchedItemNames
  );

  # Shortcuts for files/directories
  listFiles = readDirByType "regular";
  listDirs  = readDirByType "directory";

  # Returns a flattened list of .nix files recursively, except for default.nix
  # Useful for getting all Nix modules under a directory
  listNixModulesRecursive = (searchpath:
    builtins.filter
      (filepath:
        (name: lib.strings.hasSuffix ".nix" name && name != "default.nix")
        (builtins.baseNameOf filepath)
      )
      (lib.filesystem.listFilesRecursive searchpath)
  );
}

