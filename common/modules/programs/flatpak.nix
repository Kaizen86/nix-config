{ config, lib, pkgs, ... }:

let
  cfg = config.programs.flatpaks;

  mkFlatpakOption = name: id: {
    enable = lib.mkEnableOption name;
    id = lib.mkOption {
      type = lib.types.str;
      default = id;
    };
  };

  cfgValues = builtins.attrValues cfg;
  anyFlatpakEnabled = builtins.any (i: i==true)
    (map (f: f.enable)
    cfgValues);

in {
  options.programs.flatpaks = {
    surfshark = mkFlatpakOption "Surfshark" "com.surfshark.Surfshark";
    ktailctl = mkFlatpakOption "KTailctl" "org.fkoehler.KTailctl";
  };

  config = lib.mkIf anyFlatpakEnabled {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = lib.mkDefault true;
      packages = map (p: p.id)
        (builtins.filter (p: p.enable)
        cfgValues);
    };

    # If KTailctl is installed, it only makes sense to install Tailscale as a dependency
    services.tailscale = lib.mkIf cfg.ktailctl.enable {
      enable = true;
    };
  };
}
