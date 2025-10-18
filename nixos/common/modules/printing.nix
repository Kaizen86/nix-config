{ lib, pkgs, ... }:

{
  config.services.printing = {
    enable = lib.mkDefault false;
    # Default configuration, override as appropriate
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
}

