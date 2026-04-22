{ pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    bat
    #bc
    #beep
    #bzip2
    curl
    diffutils
    dig
    dos2unix
    #duf
    #exif
    ffmpeg
    file
    findutils
    gallery-dl
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
    #hostname
    htop
    #jq
    #lftp
    #lynx # TUI web browser
    man
    #mono # Run .NET programs under Linux
    #nano
    #nanorc
    ncdu # NCurses Disk Usage
    ncurses # Provides clear and reset commands
    neofetch
    nmap
    nodePackages.http-server # Handy for quickly hosting a directory over HTTP
    openssh
    #openssl
    p7zip
    pay-respects
    #pinentry # Authentication for GPG
    python3
    # TODO insert Python deps... somewhere. Probably not here.
    # cairo, matplotlib, opencv, pip?, pip-search?, psutil?, pyserial?
    rsync
    rustup
    #screen # Detachable sessions with names
    #speedtest-cli
    #sshfs
    strace
    #sysbench
    tree
    #tzdata
    #unrar
    unzip
    util-linux
    vim
    wget
    #xz
    yt-dlp
    zip
  ];
}
