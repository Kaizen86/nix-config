{ lib }:

rec {
  readDirByType = (type: path:
    map
    # 4. Convert names to full path: [ /a/b/c/bar ];
    (n: lib.path.append path n)
    # 3. Get the file names as a list: [ "bar" ]
    (builtins.attrNames
      # 2. Select by desired type: { "bar" = "regular"; }
      (lib.filterAttrs
        (n: v: v == type)
        # 1. Get files/directories in some path: { "foo" = "directory"; "bar" = "regular"; }
        (builtins.readDir path)
      )
    )
  );

  readDirByTypeExcluding = (type: path: excluding:
    map
    # 5. Convert names to full path: [ /a/b/c/bar ];
    (n: lib.path.append path n)
    # 4. Filter any excluded names: [ "bar" ]
    (builtins.filter
      (n: builtins.any (i: n!=i) excluding)
      # 3. Get the file names as a list: [ "bar" "baz" ]
      (builtins.attrNames
        # 2. Select by desired type: { "bar" = "regular"; "baz" = "regular"; }
        (lib.filterAttrs
          (n: v: v == type)
          # 1. Get files/directories in some path: { "foo" = "directory"; "bar" = "regular"; "baz" = "regular"; }
          (builtins.readDir path)
        )
      )
    )
  );

  # Shortcuts for files/directories
  listFiles = readDirByType "regular";
  listDirs  = readDirByType "directory";
  listFilesExcluding = readDirByTypeExcluding "regular";
  listDirsExcluding  = readDirByTypeExcluding "directory";
}

