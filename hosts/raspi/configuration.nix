# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Use common configuration
      ../../common/configuration.nix
    ];

  networking.hostName = "raspi"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable UART console
  boot.kernelParams = [
    "console=ttyS1,115200n8"
  ];

  users = {
    mutableUsers = false;
    users.kaizen = {
      isNormalUser = true;
      description = "Kaizen";
      extraGroups = [ "wheel" ];
      hashedPassword = "$y$j9T$RBgkLbeMA5mObFKvQuMxc.$UNeEaMi.GCmN6syFuZWscXWBSm3A0T/Qs.EAPqWXFVB";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # TODO This is a temporary workaround for installing packages because there
  # are some defined in common/configuration.nix that won't install on aarch64.
  # The same problem is why hosts/connor is on a different branch. For now
  # I've copy-pasted the equally temporary list used by the connor host
  # SUPER-TODO Combine different lists of packages to pick-and-choose groups
  # then merge the android branch. Perhaps I'll call this "profiles"? Or maybe
  # there's some feature/technique in Nix to solve this that I don't know yet.
  environment.systemPackages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim
    git
    gnugrep
    openssh
    # Some common stuff that people expect to have
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip

    bat
    #bc
    #beep
    diffutils
    dig
    dos2unix
    #duf
    gallery-dl
    gcc
    gdb
    git
    gparted
    gnumake
    gnupg
    hackrf
    hollywood
    htop
    iotop
    #lftp
    lynx # TUI web browser
    man-db
    man-pages
    #mono # Run .NET programs under Linux
    nano
    nanorc
    ncdu # NCurses Disk Usage
    ncurses # Provides clear and reset commands
    neofetch
    nmap
    nodePackages.http-server # Handy for quickly hosting a directory over HTTP
    pinentry # Authentication for GPG
    # TODO insert Python deps... somewhere. Probably not here.
    # cairo, matplotlib, opencv, pip?, pip-search?, psutil?, pyserial?
    rsync
    rustup
    screen # Detachable sessions with names
    speedtest-cli
    #sshfs
    strace
    #sysbench
    tree
    #unrar
    vim
    wget
    yt-dlp
    zip
  ];

}

