{ customLib, ... }:

{
  imports = customLib.fs.listNixModulesRecursive ./.;
}
