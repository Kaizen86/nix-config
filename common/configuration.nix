# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      #inputs.home-manager.nixosModules.default
      ./main-user.nix
    ];


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Make /tmp volatile
  boot.tmp.useTmpfs = true;

  # Enable networking
  networking.networkmanager.enable = true;

  main-user.enable = true;
  main-user.userName = "kaizen";

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "uk";

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
    
      # Enable the KDE Plasma Desktop Environment as default option.
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      displayManager.defaultSession = "plasmawayland";

      # Configure keymap in X11
      xkb = {
        layout = "gb";
        variant = "";
      };
    };

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
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    # TODO Find out where I goofed during Vimjoyer's tutorial
    #specialArgs = { inherit inputs; };
    users = {
      "kaizen" = import ./home.nix;
    };
  };

  # List packages installed in system profile. 
  # TODO There must be a way to organise this... Maybe separate user programs from system utilities?
  environment.systemPackages = with pkgs; [
    acpid # Power button forces shutdown
    adbfs-rootless # Mounting phone
    alsaequal # Equaliser
    amdgpu_top
    arduino
    audacity
    bat
    #bc
    #beep
    bitwarden
    blender
    #cdrdao # CD tools
    #cheese # Webcam tool
    #cimg # Forgot why this was installed
    #cmake # Pi Pico toolchain?
    cool-retro-term
    deja-dup # Backup manager (TODO Load old config!)
    dejavu_fonts # DejaVu Sans/Serif/Mono fonts; broad coverage of Unicode
    discord
    dos2unix
    #duf
    #dvd+rw-tools
    #exfatprogs
    #ffmpegthumbs # Show previews for video files in Dolphin (NOTE maybe not required on nix?)
    filelight
    firefox
    #flashplayer-standalone
    gallery-dl
    gimp
    git
    gnome.ghex
    gnome.gnome-clocks
    gnome.gnome-disk-utility
    gparted
    gnumake
    gnupg
    hackrf
    hollywood
    htop
    iotop
    kdenlive
    kdiff3
    #kicad
    #kicad-library
    #kicad-library-3d
    #kimageformats # Show previews for uncommon image types (e.g. .xcf) in Dolphin (NOTE maybe not required on nix?)
    #krita
    #lftp
    #libdvdcss
    liberation_ttf # Replacements for Arial, Times New Roman, and Courier New fonts
    #libisoburn
    #libnbd # tom7/pingu
    libreoffice-fresh
    #lutris
    lynx # TUI web browser
    man-db
    man-pages
    minecraftia # MC font
    minicom # Fancy serial port client
    #mono # Run .NET programs under Linux
    #movit # May be needed for some Kdenlive effects
    mpv
    nano
    nanorc
    #nasm # Dependency for my old Assembly projects circa-Berkeley
    #nbd # tom7/pingu
    #nbdkit # tom7/pingu
    ncdu # NCurses Disk Usage
    neofetch
    nmap
    nodePackages.http-server # Handy for quickly hosting a directory over HTTP
    noto-fonts-cjk # Noto Sans/Serif
    noto-fonts-emoji
    ntfs3g # Allows mounting NTFS partitions
    obs-studio
    openscad # Funny code-based 3D design tool (thanks Steve <3)
    pavucontrol # PulseAudio Volume Controls
    pinentry # Authentication for GPG
    plasma-systemmonitor
    prismlauncher # Alternative Minecraft launcher
    #posy-cursors # TODO Contribute this package perhaps?
    python3
    python311Packages.pip
    # TODO insert Python deps... somewhere. Probably not here.
    # cairo, matplotlib, opencv, pip?, pip-search?, psutil?, pyserial?
    qFlipper
    radeontop
    rsync
    rustup
    s-tui # Fancy TUI graphs for system temperature
    scrcpy # Show&control Android screen over ADB
    screen # Detachable sessions with names
    sidequest
    speedcrunch
    speedtest-cli
    #sqlitebrowser
    #sshfs
    steam
    strace
    #subversion # tom7's repo
    #sysbench
    #teams # NOTE lmfao not supported on this platform? Not a huge loss tbh
    telegram-desktop
    #testdisk # Data recovery tool
    thunderbird
    transmission-qt
    tree
    #unrar
    #v4l2loopback-dkms # OBS Virtual Camera driver (NOTE: Not sure if still needed or even compatible)
    vice # Commodore Emulator
    vim
    #virtualbox
    vlc
    vscodium
    wget
    whatsapp-for-linux
    #wine
    xorg.xeyes
    yt-dlp
    zip
];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  
  #Enable gpg service and add the input tty env var
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };
  environment.sessionVariables = rec { 
    GPG_TTY = "$(tty)";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
