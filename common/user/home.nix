{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kaizen";
  home.homeDirectory = "/home/kaizen";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    #pkgs.firefox
    #pkgs.kate
    #pkgs.thunderbird
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # MaKe and Change Directory
    (pkgs.writeShellScriptBin "mkcd" ''
        mkdir -p "$@" && cd "$@";
     '')
    # Often I want to try out a program by installing it ephemerally
    # This immediately starts the program after it finishes downloading
    (pkgs.writeShellScriptBin "nix-tryout" ''
        nix-shell -p $1 --command $1
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".face.icon".source = dotfiles/avatar.png;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".ssh/config".text = ''
      Host kaizen86.uk
      #User kaizen
      Port 58913
    '';

    ".vimrc".source = dotfiles/vimrc;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kaizen/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    # [username@hostname:~/folder]
    # $
    PS1 = "\\n\\[\\e[34;1m\\][\\[\\e]0;\\w\\a\\]\\u@\\h:\\w\\n\\[\\e[0m\\]\\$ ";
  };

  home.shellAliases = {
    ffmpeg = "ffmpeg --hide_banner";
    music-dl = "yt-dlp -ciwx --audio-format flac --embed-thumbnail --add-metadata -o \%\(title\)s.\%\(ext\)s";
    open = "xdg-open";
    xxd = "xxd -a";
  };

  programs.bash = {
    # Note: Bash must be explicitly enabled for shellAliases to work
    # https://discourse.nixos.org/t/home-shellaliases-unable-to-set-aliases-using-home-manager/33940/4
    enable = true;
    # Note: environment variables are setup via .profile, which only applies to the login shell
    # This sources the responsible script directly
    # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/7
    initExtra = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };
}
