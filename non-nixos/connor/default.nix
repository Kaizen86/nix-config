{ pkgs, ... }@inputs:

let
  # hack: relative imports! eww
  pluckCommon = relpath: import
    (../../common + relpath)
    inputs;

  extendedInputs = inputs // {
    inherit pluckCommon;
  };

in {
  imports = map
    (f: import f extendedInputs)
    [
      ./configuration.nix
      ./packages.nix
    ];
}
