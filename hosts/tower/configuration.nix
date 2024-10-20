# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
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

  # Activate Bluetooth on boot
  # TODO: This should probably be set to true by default in some other file
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  programs.steam.enable = true;
  # Fix Steam glXChooseVisual error
  hardware.graphics.enable32Bit = true;

  # Install packages
  environment.systemPackages = with pkgs; [
    gamemode # gamemoderun for Steam
    cargo
    bambu-studio
    freecad
    gqrx
    gnuradio
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs.adb.enable = true;
  users.users.kaizen.extraGroups = [ "adbusers" ];
}
