{ config, lib, pkgs, ... }:

{
  config.services.printing = {
    enable = lib.mkDefault false;
    # Default configuration, override as appropriate
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  # KDE wants this package installed to aid the printer service
  config.environment.systemPackages =
    (if config.services.printing.enable then
      [ pkgs.system-config-printer ] else []);
}

