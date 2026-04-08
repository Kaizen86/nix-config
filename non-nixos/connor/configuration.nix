{ pkgs, lib, ... }:

let
  # hack: relative imports! eww
  pluckCommon = relpath: import (../../common + relpath) { inherit pkgs lib; };
  homeCfg = lib.filterAttrsRecursive
    (name: value:
      # Some home-manager configuration keys are not valid in nix-on-droid, so filter them out before ingesting
      !builtins.elem name [ "username" "homeDirectory" "plasma" ]
    )
    (pluckCommon /user/home.nix);

  gitCfg = {
    programs.git = {
      enable = true;
      settings = (pluckCommon /modules/git.nix).config.programs.git.config
	    // { commit.gpgsign = false; }; # No GPG on mobile, thx
    };
  };

in {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  home-manager.config = lib.attrsets.recursiveUpdate homeCfg gitCfg;
  #home-manager.useGlobalPkgs = true; # don't need this i think...
  home-manager.useUserPackages = true;
}
