{ lib, config, pkgs, inputs, ... }:

let
  cfg = config.main-user;
in
{
  options = {
    main-user.enable
      = lib.mkEnableOption "enable user module";

    main-user.userName = lib.mkOption {
      default = "user";
      description = ''
        username
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "Kaizen";
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
      # I don't know what the extraSpecialArgs is for; it works fine without that
      # I know it's for passing 'inputs' into home-manager, but I don't know why we do that...
      extraSpecialArgs = { inherit inputs; };
      users = {
        "kaizen" = import ./home.nix;
      };
    };

    # Hacky workaround to make the profile picture show on the login screen
    # Hard link to ~/.face.icon symlink will 'create' a symlink to the nix store path
    system.activationScripts.linkMainUserAvatar = lib.stringAfter [ "var" ] ''
      ln -f /home/${cfg.userName}/.face.icon /var/lib/AccountsService/icons/${cfg.userName}
    '';
  };
}

