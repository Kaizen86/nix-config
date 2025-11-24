{ lib }:

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

  # Filter names from an attribute set where the predicate (n: v: ...) returns true.
  filterAttrNames = (pred: set:
    let filteredAttrs = lib.filterAttrs pred set;
    in builtins.attrNames filteredAttrs
  );

  # Get a list of paths in a directory, filtered by item type (e.g. "regular", "directory", etc).
  readDirByType = (type: path:
    let
      dirListing = builtins.readDir path;
      # Select names where the value matches $type
      matchedItemNames = filterAttrNames
        (n: v: v==type)
        dirListing;
    in
      # Convert names to full path
      map
        (n: lib.path.append path n)
        matchedItemNames
  );

  # Like readDirByType, but accepts a list of names to filter from the output.
  readDirByTypeExcluding = (type: path: excluding:
    let
      dirListing = builtins.readDir path;
      # Select names where the value matches $type
      matchedItemNames = filterAttrNames
        (n: v: v==type)
        dirListing;
      # Filter any excluded names
      filteredItemNames = builtins.filter
        (n: builtins.any (i: n!=i) excluding)
        matchedItemNames;
    in
      map
        # Convert names to full path
        (n: lib.path.append path n)
        filteredItemNames
  );

  # Shortcuts for files/directories
  listFiles = readDirByType "regular";
  listDirs  = readDirByType "directory";
  listFilesExcluding = readDirByTypeExcluding "regular";
  listDirsExcluding  = readDirByTypeExcluding "directory";
}

