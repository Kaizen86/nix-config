{ pkgs, ... }:

{
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
    gawk # Used by bash autocompletes

    bat
    #bc
    #beep
    diffutils
    dig
    dos2unix
    #duf
    findutils
    ffmpeg
    gallery-dl
    gcc
    #gdb
    #gnumake
    #gnupg
    hollywood
    htop
    #lftp
    #lynx # TUI web browser
    man-db
    man-pages
    #mono # Run .NET programs under Linux
    #nano
    #nanorc
    ncdu # NCurses Disk Usage
    ncurses # Provides clear and reset commands
    neofetch
    nmap
    nodePackages.http-server # Handy for quickly hosting a directory over HTTP
    #pinentry # Authentication for GPG
    # TODO insert Python deps... somewhere. Probably not here.
    python3
    # cairo, matplotlib, opencv, pip?, pip-search?, psutil?, pyserial?
    rsync
    rustup
    #screen # Detachable sessions with names
    #speedtest-cli
    #sshfs
    strace
    #sysbench
    tree
    #unrar
    unzip
    vim
    wget
    yt-dlp
    zip

    curl
    p7zip
    file
    gnused
    #exif
    #openssl
    #jq
  ];
}
