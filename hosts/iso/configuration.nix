{ pkgs, modulesPath, lib, ... }:

{
  imports = [
    #"${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  # Disable default user
  # (not necessary with graphical-base)
  #users.users.nixos.enable = false;

  # Boot straight into cool-retro-term :)
  # It's not perfect, though. The cursor still appears and autologin is required.
  # But these *do* allow you to launch graphical programs, which is pretty funny.
  services = {
    cage = {
      enable = true;
      user = "kaizen";
      extraArguments = ["-d"]; # hide decorations+buttons
      program = "${pkgs.cool-retro-term}/bin/cool-retro-term";
    };
    xserver.enable = lib.mkForce false;
    desktopManager.plasma6.enable = false;
	displayManager.defaultSession = "";
    displayManager.sddm.enable = false;
  };

  # Suppress warning about new default for this option
  # TODO remove when 26.11 is released
  boot.zfs.forceImportRoot = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
