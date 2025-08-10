{ config, lib , ... }:

let
 cfg = config.steam;

in {
  options = {
    steam = {
      enable = lib.mkEnableOption "enable Steam";
      allow-game-transfer = lib.mkOption {
        default = true;
        description = "Open the network ports responsible for Local Network Game Transfer";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
    # Fix Steam glXChooseVisual error
    hardware.graphics.enable32Bit = true;

    networking.firewall = lib.mkIf cfg.allow-game-transfer {
      allowedTCPPorts = [ 27040 ];
      allowedUDPPorts = lib.range 27031 27036;
    };
  };
}
