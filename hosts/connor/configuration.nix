{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Use common configuration
      #../../common/configuration.nix
    ];

  # Simply install just the packages
  environment.packages = with pkgs; [
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

    acpid # Power button forces shutdown
    adbfs-rootless # Mounting phone
    alsaequal # Equaliser
    amdgpu_top
    arduino
    audacity
    bat
    #bc
    #beep
    #cdrdao # CD tools
    #cheese # Webcam tool
    #cimg # Forgot why this was installed
    #cmake # Pi Pico toolchain?
    dejavu_fonts # DejaVu Sans/Serif/Mono fonts; broad coverage of Unicode
    dos2unix
    #duf
    #dvd+rw-tools
    #exfatprogs
    #ffmpegthumbs # Show previews for video files in Dolphin (NOTE maybe not required on nix?)
    #flashplayer-standalone
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
    pinentry # Authentication for GPG
    #posy-cursors # TODO Contribute this package perhaps?
    # TODO insert Python deps... somewhere. Probably not here.
    # cairo, matplotlib, opencv, pip?, pip-search?, psutil?, pyserial?
    rsync
    rustup
    s-tui # Fancy TUI graphs for system temperature
    scrcpy # Show&control Android screen over ADB
    screen # Detachable sessions with names
    speedtest-cli
    #sqlitebrowser
    #sshfs
    strace
    #subversion # tom7's repo
    #sysbench
    #teams # NOTE lmfao not supported on this platform? Not a huge loss tbh
    #testdisk # Data recovery tool
    tree
    #unrar
    #v4l2loopback-dkms # OBS Virtual Camera driver (NOTE: Not sure if still needed or even compatible)
    vim
    wget
    #wine
    yt-dlp
    zip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
