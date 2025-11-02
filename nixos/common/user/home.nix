{ pkgs, ... }:

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
    # This gets run when the shell opens. Useful for defining functions
    initExtra = ''
      # Note: environment variables are setup via .profile, which only applies to the login shell
      # This sources the responsible script directly
      # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/7
      # EDIT: Somehow I fixed this when adding plasma-manager? lol
      #. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

      # MaKe then Change Directory
      # This must be in initExtra because the cd cannot run in a subshell
      function mkcd() {
        mkdir -p "$@" && cd "$@";
      }
    '';
  };

  # TODO: Put this into its own file somehow; it's getting crowded in here!
  # This may involve a refactor... Currently the import chain looks like this:
  # default.nix -> main-user.nix -> home.nix
  # Adding another link to the chain would be too messy for my liking...
  # Organising things with a folder or extending default.nix would be preferable.

  # Adapted from github:nix-community/plasma-manager/examples/home.nix
  programs.plasma = {
    enable = true;

    workspace = {
      colorScheme = "BreezeDark";
      # Use Posy's cursors
      cursor = {
        theme = "Posy_Cursor_Black";
        size = 32; # Normal size, please
      };
    };

    panels = [
      # Primary taskbar
      {
        location = "left"; # Gives slightly more space to applications
        floating = false; # I tried using this but it feels too weird to me
        height = 50;

        # See github:nix-community/plasma-manager/modules/widgets for a list of supported widgets and their options
        widgets = [
          # Application Launcher
          {
            kickoff = {
              sortAlphabetically = true; # idk what this does, i just copied from the example
              icon = "usermenu-up"; # Upwards arrow like a caret (^), which I quite like the look of
            };
          }

          # Taskbar
          {
            iconTasks = {
              # Declaratively pin applications, yEAAA!!
              # See /run/current-system/sw/share/applications for a list
              launchers = [
                "preferred://filemanager"
                #"preferred://terminal" # Supposed to work but doesn't? https://discuss.kde.org/t/any-documentation-for-preferred-uri-schema/30689/5
                "applications:org.kde.konsole.desktop"
                "preferred://browser"
                "applications:org.kde.kate.desktop"
                "applications:discord.desktop"
                "applications:steam.desktop"
                "applications:org.telegram.desktop.desktop"
              ];
            };
          }

          # Margin separator before the system tray
          # Removing this makes the clock/Show Desktop button bigger
          "org.kde.plasma.marginsseparator"

          {
            systemTray = {
              # TODO: Play around with the options
            };
          }

          {
            digitalClock = {
              # Use DD/MM because there's not enough room for the year when the panel is vertical
              date.format.custom = "dd/MM";
            };
          }

          # Right-most Show Desktop button
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

  };

}
