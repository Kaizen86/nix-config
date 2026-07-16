{ config, lib, pkgs, ... }:

let
  cfg = config.services.printing;
in {
  config = lib.mkIf cfg.enable {
    services.printing = {
      # Default configuration, override as appropriate
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };

    # KDE wants this package installed to aid the printer service
    environment.systemPackages = with pkgs; [
      system-config-printer
    ];
  };
}

