{ lib, config, pkgs, customLib, ... }:

let
  cfg = config.main-user;
in
{
  options = {
    main-user.enable = lib.mkEnableOption "main user account";

    main-user.userName = lib.mkOption {
      default = "user";
      description = ''
        username for main account
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "Kaizen";
      hashedPassword = "$y$j9T$3UMDcHyYZe0hJMU7TJIcM.$LyUivn3726ae5kHr1blHJhS7CFS.ybQ9dw/CbKoT3P3";
      extraGroups = [ 
        "networkmanager" # Grant permission to change network settings
        "wheel" # Grant permission to execute sudo
        "plugdev" # Allow access to HackRF device
        "video" # Allow access to RTL-SDR device
        "dialout" # Allow access to serial ports
      ];
      shell = pkgs.bash;
    };

    home-manager = {
      extraSpecialArgs = { inherit customLib; };
      users = {
        "kaizen" = import ./home.nix;
      };
    };

    # Hacky workaround to make the profile picture show on the login screen
    # Hard link to ~/.face.icon symlink will 'create' a symlink to the nix store path
    # FIXME: this does not work on first activation because it runs *before* home-manager! :(
    /*
    system.activationScripts.linkMainUserAvatar = lib.stringAfter [ "var" ] ''
      ln -f /home/${cfg.userName}/.face.icon /var/lib/AccountsService/icons/${cfg.userName}
    '';
    */
  };
}

