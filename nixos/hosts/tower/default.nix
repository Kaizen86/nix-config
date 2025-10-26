{ customLib, ... }:

{
  imports = customLib.listFilesExcluding ./. [ "default.nix" ];
}
