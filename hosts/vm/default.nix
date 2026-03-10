{ customLib, ... }:

{
  imports = customLib.fs.listFilesExcluding ./. [ "default.nix" ];
}
