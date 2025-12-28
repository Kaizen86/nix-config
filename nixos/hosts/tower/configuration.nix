# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

{
  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # Tell wayland to use AMD drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Define hostname.
  networking.hostName = "tower";

  programs = {
    # Set GPG key
    git.config.user.signingkey = "029A86F4E8D375F2";

    steam.enable = true;
  };

  # Install packages
  environment.systemPackages = with pkgs; [
    gamemode # gamemoderun for Steam
    cargo
    freecad
    gqrx
    gnuradio
  ];

  programs.orca-slicer.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 8080
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Install ADB
  programs.adb.enable = true;
  users.users.kaizen.extraGroups = [ "adbusers" ];
}
