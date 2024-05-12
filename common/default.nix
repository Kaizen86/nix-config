# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./packages.nix
      ./modules 
      ./user/main-user.nix
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  # Enable flakes :)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  main-user.enable = true;
  main-user.userName = "kaizen";

  services = {
    # Allow power button to shutdown system
    # FIXME This doesn't work??
    logind.extraConfig = ''
      # Shutdown system when power button is pressed
      HandlePowerKey=poweroff
    '';

    # X11 windowing system
    xserver = {
      enable = true;
      # Enable the Plasma desktop environment (TODO: is this necessary?)
      desktopManager.plasma5.enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "gb";
        variant = "";
      };
    };

    # Enable the KDE Plasma Desktop Environment as default option.
    displayManager.sddm.enable = true;
    displayManager.defaultSession = "plasmawayland";

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
        addresses = true;
      };
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  
  #Enable gpg service and add the input tty env var
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry;
    enableSSHSupport = true;
  };
  environment.sessionVariables = rec { 
    GPG_TTY = "$(tty)";
  };

  hardware.hackrf.enable = true; # Create udev rules for HackRF devices
  services.udev.packages = [ pkgs.rtl-sdr ];
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
}
