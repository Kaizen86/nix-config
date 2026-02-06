{ config, lib, pkgs, ... }:

{
  services.flatpak = {
    enable = lib.mkDefault true;
    uninstallUnmanaged = lib.mkDefault true;
    packages = lib.mkOptionDefault [
      "com.surfshark.Surfshark"
    ];
  };
}
