{ pkgs, ... }:
# TODO install nix-inspect to make my life easier

# Pattern adapted from https://github.com/JRMurr/NixOsConfig/blob/main/common/programs.nix :3
# FIXME Some of these should get their own module so they can be installed properly!
let
  # TODO setup some kind of equivalent
  #myOpts = config.myOptions;
  #gcfg = myOpts.graphics;
  #mcfg = myOpts.musicPrograms;

  installOnEverything = with pkgs; [
    bat
    binutils
    dig
    file
    gnupg # TODO Enable+configure elsewhere
    htop
    iotop # Like top, but for disk I/O :)
    killall
    lsof
    man man-db man-pages
    nano nanorc # Just in case
    pinentry # Authentication for GPG
    rsync
    screen # Detachable sessions with names
    strace
    tree
    unrar
    unzip
    usbutils
    vim # *epic electric guitar riff*
    wget
    zip
  ];

  # FIXME this is unused, perhaps I made too many categories to keep track of...
  devTools = with pkgs; [
    gnumake
    rustup
  ];

  desktopApplications = with pkgs; [
    alsaequal # Equaliser
    arduino-ide
    audacity
    bitwarden
    blender-hip
    cool-retro-term
    deja-dup
    discord
    firefox
    ghex
    gimp3
    gnome-clocks
    gnome-disk-utility
    gparted
    kdePackages.filelight
    kdePackages.kate
    kdePackages.kdenlive
    kdePackages.plasma-systemmonitor
    kdiff3
    #kicad
    #krita
    #lutris
    mpv # Simple video player
    obs-studio #v4l2loopback-dkms # NOTE idk if OBS still needs the virtual webcam driver
    onlyoffice-desktopeditors
    obsidian
    openscad # Funny code-based 3D design tool (thanks Steve <3)
    pavucontrol # PulseAudio Volume Controls
    # TODO figure out where cursor packages should sit (posy-cursors)
    posy-cursors
    prismlauncher # Alternative Minecraft launcher
    qFlipper
    sidequest # Unoffical Oculus VR headset manager
    speedcrunch # Neat calculator
    telegram-desktop
    thunderbird
    transmission_4-qt
    #vice # Commodore retro-computer emulator
    #virtualbox
    vlc
    vscodium
    whatsapp-for-linux
  ];

  fontPackages = with pkgs; [
    dejavu_fonts # DejaVu Sans/Serif/Mono fonts; broad coverage of Unicode 
    liberation_ttf # Replacements for Arial, Times New Roman, and Courier New fonts
    minecraftia
    noto-fonts-cjk-sans # Noto Sans/Serif
    noto-fonts-emoji
  ];

  pythonPackages = with pkgs; [
    python3Full
    python311Packages.pip
  ];

  niceToHave = with pkgs; [
    adbfs-rootless # Mounting android phone
    dos2unix
    ffmpeg
    gallery-dl
    hollywood # lmao
    #lftp
    ncdu # NCurses Disk Usage
    lynx
    minicom # Fancy serial port client
    nmap
    nodePackages.http-server # Handy for quickly hosting a directory over HTTP
    scrcpy # Show&control Android screen over ADB
    speedtest-cli
    #sshfs
    #sysbench
    yt-dlp
  ];

  systemTools = with pkgs; [
    acpid # Used to detect power button press for quick shutdown
    amdgpu_top
    #dvd+rw-tools
    #exfatprogs
    #libdvdcss
    #libisoburn
    ntfs3g # Allows mounting NTFS partitions (TODO This might be deprecated?)
    #radeontop
    s-tui # Fancy TUI graphs for system temperature
    #testdisk # Data recovery tool
  ];

in {
  environment.systemPackages =
    installOnEverything ++ 
    desktopApplications ++ 
    fontPackages ++
    pythonPackages ++
    niceToHave ++
    systemTools;
}
