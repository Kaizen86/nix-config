{ config, lib, pkgs, ... }:

let
  cfg = config.programs;
  mkFlatpakOption = name: id: {
    enable = lib.mkEnableOption name;
    id = lib.mkOption {
      type = lib.types.str;
      default = id;
    };
  };

in {
  options.programs = {
    surfshark = mkFlatpakOption "Surfshark" "com.surfshark.Surfshark";
    ktailctl = mkFlatpakOption "KTailctl" "org.fkoehler.KTailctl";
  };

  config = lib.mkIf (cfg.surfshark.enable || cfg.ktailctl.enable) {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = lib.mkDefault true;
      packages = lib.lists.concatMap
        (c: if c.enable then [c.id] else [])
        [cfg.surfshark cfg.ktailctl];
    };
  };
}
