{ customLib, ... }:

{
  imports =
    (customLib.fs.listFilesExcluding ./. [ "default.nix" ]) ++
    (customLib.fs.listFiles ./programs);
}
