{ pluckCommon, ... }:

let
  # NixOS modules aren't implemented on NOD, so we configure Git through home-manager instead.
  nixosGitCfg = (pluckCommon /modules/programs/git.nix).config.programs.git.config;

in {
  programs = {
    git = {
      enable = true;
      # Thankfully the options can be passed through here without modification
      settings = nixosGitCfg // {
        commit.gpgsign = false; # No GPG on mobile, thx
      };
    };

    # Where we're going, we don't need IDEs...
    vscodium.enable = false;

    # mDNS is not available, so add my PC to ssh manually
    # RPi is already tracked due to its wacky port number
    ssh.settings.tower = {
      HostName  = "192.168.1.69";
      User = "kaizen";
    };
  };
}
