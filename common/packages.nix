{ config, lib, pkgs, ... }:

# Pattern inspired by https://github.com/JRMurr/NixOsConfig/blob/main/common/programs.nix :3
# NOTE Some of these should get their own module so they can be installed properly!
let
  categories = with pkgs; {
    installOnEverything = [
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

    desktopApplications = [
      alsaequal # Equaliser
      arduino-ide
      audacity
      #bitwarden-desktop # FIXME: https://github.com/NixOS/nixpkgs/issues/526914
      pkgsRocm.blender # Enable HIP (AMD GPU) support
      cool-retro-term
      deja-dup
      discord
      easyeffects
      firefox
      ghex
      gimp3
      gnome-clocks
      gnome-disk-utility
      gparted
      karere # WhatsApp for linux
      kdePackages.filelight
      kdePackages.kate
      kdePackages.kdenlive
      kdePackages.plasma-systemmonitor
      kdiff3
      #kicad
      #krita
      libreoffice
      #lutris
      mpv # Simple video player
      obs-studio #v4l2loopback-dkms # NOTE idk if OBS still needs the virtual webcam driver
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
    ];

    fontPackages = [
      dejavu_fonts # DejaVu Sans/Serif/Mono fonts; broad coverage of Unicode
      liberation_ttf # Replacements for Arial, Times New Roman, and Courier New fonts
      minecraftia
      noto-fonts-cjk-sans # Noto Sans/Serif
      noto-fonts-color-emoji
    ];

    pythonPackages = [
      python313
      python313Packages.pip
      # failed experiment to stop sphinx from failing to build the docs :(
      #(python315.overrideAttrs { passthru.doc=null; })
      #python315Packages.pip
    ];

    niceToHave = [
      adbfs-rootless # Mounting android phone
      dos2unix
      ffmpeg
      gallery-dl
      hollywood # lmao
      #lftp
      http-server # Handy for quickly hosting a directory over HTTP
      ncdu # NCurses Disk Usage
      lynx
      minicom # Fancy serial port client
      nmap
      pay-respects # Bad command corrector
      scrcpy # Show&control Android screen over ADB
      speedtest-cli
      #sshfs
      #sysbench
      yt-dlp
    ];

    systemTools = [
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
  };

  cfg = config.packageSets;

in with lib; {
  options.packageSets =
    lib.mapAttrs (n: pkgs: {
      enable = mkOption {
        type = types.bool;
        description = "Install packages from the "+n+" category";
        default = true;
      };
      pkgs = mkOption {
        type = types.listOf types.package;
        description = "List of packages in this category";
        default = pkgs;
      };
    }) categories;

  config.environment.systemPackages =
    builtins.concatMap (i: i.pkgs) (
      attrValues
      (filterAttrs (n: v: v.enable) cfg)
    );
}
