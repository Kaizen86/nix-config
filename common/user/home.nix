{ pkgs, lib, customLib, ... }:

{
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
    })
    (customLib.fs.listFiles ./dotfiles))
  );

  # Symlink plain xdg config files
  # e.g dotfiles/config/mimeapps.list -> ~/.config/mimeapps.list
  xdg.configFile = builtins.listToAttrs (
    (map (file: {
      name = builtins.baseNameOf file;
      value.source = file;
    })
    (customLib.fs.listFiles ./dotfiles/config))
  );

  # TODO manage with a Nix module
  /*
  home.file = {
    ".ssh/config".text = ''
      Host punyoracle
      Hostname 145.241.222.171
      Port 58913
      User kaizen

      Host rpi
      Hostname 192.168.1.50
      Port 58913
      User kaizen
    '';
  };
  */

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

    # Often I want to try out a program by installing it ephemerally.
    # This function immediately starts the program with arguments after it finishes downloading.
    # Optionally allows specifying a different command name by passing --
    (pkgs.writeShellScriptBin "nix-tryout" ''
        #!/usr/bin/env bash
        # First argument is always package to use
        package="$1"
        if [ -z "$package" ]; then
            echo No package specified
            exit 1
        fi
        # Parse extra arguments
        shift
        case "$1" in
            "--")
                shift
                command="$1"
                shift
                ;;
            *)
                command="$package"
                ;;
        esac
        args="$@"

        # Check if this package is unfree
        unfree=$(nix-instantiate --eval --expr "(import <nixpkgs> {}).$package.meta.unfree")
        # Set magic environment variable if necessary
        if [ $unfree == true ]; then
            echo This package is unfree, setting NIXPKGS_ALLOW_UNFREE=1 and proceeding...
            export NIXPKGS_ALLOW_UNFREE=1
        fi
        # Run it
        nix shell --impure nixpkgs#$package --command $command $args
        exit $?
    '')

    # Display meta information about a package
    (pkgs.writeShellScriptBin "nix-query" ''
        package=$1
        if [ -z "$package" ]; then
            echo No package specified
            exit 1
        fi

        nix eval --impure --raw --pretty --expr "
            let
              nixpkgs = import <nixpkgs> {};
              lib = nixpkgs.lib;
            in
              lib.generators.toPretty {} nixpkgs.$package.meta"
    '')

    # Pipe grep output to less, with colours enabled
    (pkgs.writeShellScriptBin "grepless" ''
        grep --color=always -rn "$@" | less -R
    '')

  ];

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
      # Use Posy's cursors (installed via environment.systemPackages)
      cursor = {
        theme = "Posy_Cursor_Black";
        size = 32; # Normal size, please
      };

      # Select items when single-clicking, not open
      # Windows behaviour
      clickItemTo = "select";
    };
    session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";

    # Meta+Shift+K
    input.keyboard.layouts = lib.mkDefault [
      { layout = "gb"; }
    ];

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
              icon = "ime-emoji"; # I can't fucking believe there's a built-in ">:3" icon holy shit lmao
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
                "applications:obsidian.desktop"
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
              # Use day/month because there's not enough room for the year when the panel is vertical
              date.format.custom = "dd/MM";
            };
          }

          # Right-most Show Desktop button
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

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
