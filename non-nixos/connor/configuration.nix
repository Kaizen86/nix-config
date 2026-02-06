{ pkgs, lib, ... }:

{
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  home-manager.config = lib.filterAttrsRecursive
    (name: value:
      # Some home-manager configuration keys are not valid in nix-on-droid, so filter them out before ingesting
      !builtins.elem name [ "username" "homeDirectory" "plasma" ]
    )
    # hack: relative import! eww
    (import ../../common/user/home.nix
      { inherit pkgs lib; }
    );
  #home-manager.useGlobalPkgs = true; # don't need this i think...
  home-manager.useUserPackages = true;
}
