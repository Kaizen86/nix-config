{ config, lib, pkgs, ... }:

# Pattern inspired by https://github.com/JRMurr/NixOsConfig/blob/main/common/programs.nix :3
# NOTE Some of these should get their own module so they can be installed properly!
let
  categories = with pkgs; {
    base = {
      description = "Only the essentials, never leave $HOME without them :)";
      pkgs = [
        binutils
        diffutils
        findutils
        gawk # Used by bash autocompletes
        git # nix flake dependency
        gnugrep
        gnused
        gnutar
        gzip
        gnupg # TODO Enable+configure elsewhere
        htop
        killall
        lsof
        man man-db man-pages
        nano nanorc # Just in case
        openssh
        ps
        rsync
        strace
        tree
        #unrar
        unzip
        vim # *epic electric guitar riff*
        wget
        zip
      ];
    };

    # TODO Hey, you know what would be cool?
    # Nested package sets.
    # Then you could have something like:
    # graphical = {
    #   desktopApplications = { ... };
    #   fonts = { ... };
    #   cursors = { ... };
    # };
    # Then, if you don't want anything graphical;
    # graphical.enable = false;

    desktopApplications = {
      description = "Graphical programs";
      pkgs = [
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
        prismlauncher # Alternative Minecraft launcher
        qFlipper
        sidequest # Unoffical Oculus VR headset manager
        speedcrunch # Neat calculator
        telegram-desktop
        thunderbird
        transmission_4-qt
        #vice # Commodore retro-computer emulator
        #virtualbox # TODO Needs its own module
        vlc
        vscodium
      ];
    };

    fontsAndCursors = {
      description = "Packages to improve GUI experience";
      pkgs = [
        dejavu_fonts # DejaVu Sans/Serif/Mono fonts; broad coverage of Unicode
        liberation_ttf # Replacements for Arial, Times New Roman, and Courier New fonts
        minecraftia
        noto-fonts-cjk-sans # Noto Sans/Serif
        noto-fonts-color-emoji
        posy-cursors # My favourite cursors ^-^
      ];
    };

    niceToHave = {
      description = "Non-essential CLI programs, but I generally like to have them around";
      pkgs = [
        bat # Like cat but with syntax highlighting :)
        curl
        dig # DNS diagnosics
        dos2unix
        ffmpeg
        file
        gallery-dl
        hollywood # lmao
        http-server # Handy for quickly hosting a directory over HTTP
        #lftp
        lynx # TUI web browser, because why not?
        minicom # Fancy serial port client
        ncdu # NCurses Disk Usage
        nix-output-monitor # nom for short. omnomnom
        nmap
        #p7zip
        python313
        screen # Detachable sessions with names
        speedtest-cli
        #sshfs
        #sysbench
        yt-dlp
      ];
    };

    androidTools = {
      enable = false; # Opt-in
      description = "Programs which communicate with Android devices over ADB";
      pkgs = [
        adbfs-rootless # Mount filesystem via ADB and FUSE
        scrcpy # View and control over USB
      ];
    };

    systemTools = {
      description = "Utilities which do hardware-related things. Not suitable to install on sandboxed environments such as nix-on-droid.";
      pkgs = [
        acpid # Used to detect power button press for quick shutdown
        amdgpu_top
        #dvd+rw-tools
        #exfatprogs
        iotop # Like top, but for disk I/O :)
        #libdvdcss
        #libisoburn
        ntfs3g # Allows mounting NTFS partitions (TODO This might be deprecated?)
        #radeontop
        s-tui # Fancy TUI graphs for system temperature
        #testdisk # Data recovery tool
        usbutils
        util-linux
      ];
    };
  };

  # TODO is packageSets really the best name?
  cfg = config.packageSets;

in with lib; {
  # TODO refactor lambda to a mkSetOption function
  # Perhaps it could have a syntax like so?
  # base = mkSetOption { desc... } [ foo bar ];

  options.packageSets =
    lib.mapAttrs (n: {description, pkgs, enable?true}: {
      enable = mkOption {
        type = types.bool;
        inherit description;
        default = enable;
      };
      pkgs = mkOption {
        type = types.listOf types.package;
        description = "List of packages included in the '"+n+"' category";
        default = pkgs;
      };
    }) categories;

  config.environment.systemPackages =
    builtins.concatMap (c: c.pkgs) (
      attrValues
      (filterAttrs (n: opt: opt.enable) cfg)
    );

  # I would like these enabled by default, and this file seems like a sensible place to put that.
  config.programs.flatpaks = {
    surfshark.enable = true;
    ktailctl.enable = true;
  };

  # TODO: Some programs have their own modules, but I don't know if/how they can be integrated into the concept of package sets.
  # Package sets refer to environment.systemPackages, so maybe it's best to not complicate it by mixing program modules in.
  # Come back to this when I've had more time to think about it
}
