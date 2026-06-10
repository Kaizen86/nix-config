{ lib, pkgs, pluckCommon, ... }:

let
  imported = pluckCommon /packages.nix;
  # Rename systemPackages -> packages
  patched = imported // {
    config.environment = builtins.removeAttrs 
      imported.config.environment [ "systemPackages" ] // {
        packages=imported.config.environment.systemPackages; 
      };
  };

# Evil hack to use the regular import as a module while also configuring/extending it
# https://discourse.nixos.org/t/import-list-in-configuration-nix-vs-import-function/11372/8
in lib.traceVal (lib.recursiveUpdate
  {
    config.packageSets = {
      desktopApplications.enable = false;
      fontsAndCursors.enable = false;
      androidTools.enable = false;
      systemTools.enable = false;
    };
  
    # Simply install just the packages
    config.environment.packages = with pkgs; [
      curl
      diffutils
      #duf
      #exif
      findutils
      gawk # Used by bash autocompletes
      gcc
      #gdb
      gnugrep
      #gnumake
      #gnupg
      gnused
      gnutar
      gzip
      hollywood
      #jq
      #lftp
      #mono # Run .NET programs under Linux
      ncurses # Provides clear and reset commands
      openssh
      #openssl
      p7zip
      pay-respects
      #pinentry # Authentication for GPG
      rsync
      rustup
      #screen # Detachable sessions with names
      #speedtest-cli
      #sshfs
      #sysbench
      #tzdata
      #unrar
      util-linux
      wget
      #xz
      yt-dlp
    ];
  }
  patched
)

