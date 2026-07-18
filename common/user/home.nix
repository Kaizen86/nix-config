{ pkgs, lib, customLib, ... }:

{
  imports = [
    ./kde-plasma.nix
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kaizen";
  home.homeDirectory = "/home/kaizen";

  # Symlink plain dotfiles
  # e.g dotfiles/face.icon -> ~/.face.icon
  home.file = builtins.listToAttrs (
    (map (file: {
      name = "." + builtins.baseNameOf file;
      value.source = file;
    }) (customLib.fs.listFiles ./dotfiles))
  );

  # Symlink plain xdg config files
  # e.g dotfiles/config/mimeapps.list -> ~/.config/mimeapps.list
  xdg.configFile = builtins.listToAttrs (
    (map (file: {
      name = builtins.baseNameOf file;
      value.source = file;
    }) (customLib.fs.listFiles ./dotfiles/config))
  );

  # FIXME: evaluation warning: kaizen profile: `programs.ssh` default values will be removed in the future.
  # Consider setting `programs.ssh.enableDefaultConfig` to false,
  # and manually set the default values you want to keep at
  # `programs.ssh.settings."*"`.
  programs.ssh = {
    enable = true;
    settings = {
      punyoracle = {
        HostName = "145.241.222.171";
        Port = 58913;
        User = "kaizen";
      };
      rpi = {
        HostName = "192.168.1.50";
        Port = 58913;
        User = "kaizen";
      };
    };
  };

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

  ] ++ (map
    (p: (pkgs.writeShellScriptBin
      (lib.removeSuffix ".sh" (builtins.baseNameOf p))
      (builtins.readFile p)
	)) (customLib.fs.listFiles ./text/shell-scripts)
  );

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
  };

  home.shellAliases = {
    ffmpeg = "ffmpeg -hide_banner";
    ffprobe = "ffprobe -hide_banner";
    ssh-load = "eval $(ssh-agent) && ssh-add";
    music-dl = "yt-dlp -ciwx --audio-format flac --embed-thumbnail --add-metadata -o \%\(title\)s.\%\(ext\)s";
    open = "xdg-open";
    xxd = "xxd -a";
  };

  programs.bash = {
    # Note: Bash must be explicitly enabled for shellAliases to work
    # https://discourse.nixos.org/t/home-shellaliases-unable-to-set-aliases-using-home-manager/33940/4
    enable = true;
    # This gets run when the shell opens. Useful for defining functions which can't run in subshells.
    initExtra = builtins.readFile ./text/bashrc;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
