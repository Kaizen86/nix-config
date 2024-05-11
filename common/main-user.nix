{ lib, config, pkgs, ... }:

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
      ];
      shell = pkgs.bash;
    };
  };
}

