{ pkgs, modulesPath, lib, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  # Disable default user
  users.users.nixos.enable = false;

  # Suppress warning about new default for this option
  # TODO remove when 26.11 is released
  boot.zfs.forceImportRoot = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
