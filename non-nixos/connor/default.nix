{ lib, pkgs, ... }@inputs:

let
  # hack: relative imports! eww
  pluckCommon = relpath: import
    (../../common + relpath)
	{ inherit lib pkgs; };

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
