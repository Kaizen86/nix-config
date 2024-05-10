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
      extraGroups = [ "networkmanager" "wheel" "plugdev" ];
      shell = pkgs.bash;
    };
  };
}

