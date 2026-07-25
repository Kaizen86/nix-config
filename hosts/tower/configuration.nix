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

  packageSets.androidTools.enable = true;

  # Install extra packages
  environment.systemPackages = with pkgs; [
    android-tools # adb
    gamemode # gamemoderun for Steam
    cargo
    freecad
    gqrx
    gnuradio
    chromium # for launcher.keychron.com
    prismlauncher
    heroic
  ];

  programs.orca-slicer.enable = true;

  # Install Tailscale so I can access the management pages of my web server
  services.tailscale.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 8080
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Install ADB
  #users.users.kaizen.extraGroups = [ "adbusers" ];

  # Allow launcher.keychron.com to access devices through chromium
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", MODE:="666"
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
