# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

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

  # Install NetworkManager for WiFi
  networking.networkmanager.enable = true;

  # Define hostname.
  networking.hostName = "laptop";

  # Activate Bluetooth on boot
  # TODO: This should probably be set to true by default in some other file
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  programs = {
    # Set GPG key
    git.config.user.signingkey = "8142D3E03705FD1A";

    steam.enable = true;
  };

  # Install packages
  environment.systemPackages = with pkgs; [
    gqrx
    gnuradio
    freecad
    nil # Nix language server (TODO: put this into a dev-tools module)
  ];
 }
