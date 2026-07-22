{ pkgs, lib, pluckCommon, ... }:

let
  homeCfg = lib.filterAttrsRecursive
    (name: value:
      # Some home-manager configuration keys are not valid in nix-on-droid, so filter them out before ingesting
      # FIXME Find a solution for ssh configs
      !builtins.elem name [ "username" "homeDirectory" "ssh" "imports" ]
    )
    (pluckCommon /user/home.nix);

  nixosGitCfg = (pluckCommon /modules/programs/git.nix).config.programs.git.config;

  gitCfg = {
    programs.git = {
        enable = true;
        # Thankfully the options can be passed through here without modification
        extraConfig = nixosGitCfg // {
          commit.gpgsign = false; # No GPG on mobile, thx
      };
    };
  };

  patchedHomeCfg = lib.attrsets.recursiveUpdate homeCfg gitCfg;
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

  home-manager.config = patchedHomeCfg;
  #home-manager.useGlobalPkgs = true; # don't need this i think...
  home-manager.useUserPackages = true;
}
