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

  xdg = (
    let
      # Given some top-level directory, return the relative path of an item as a string.
      # e.g: relativeTo ./. ./foo/bar -> "foo/bar"
      relativeTo = (root: item: 
        builtins.substring
          (builtins.stringLength (toString root) + 1)
          (-1)
          (toString item)
      );

      # Produce nameValuePairs of relative paths to file contents, under some directory.
      # Suitable for xdg configFile/dataFile/cacheFile/stateFile (and perhaps more).
      # e.g discoverFiles ./foo -> [{ name="bar/baz.txt"; value.source=./foo/bar/baz.txt; }]
      discoverFiles = (dir:
        builtins.listToAttrs (
          (map (file: {
            name = relativeTo dir file;
            value.source = file;
          }) (lib.filesystem.listFilesRecursive dir))
        )
      );
    in {
      # Symlink xdg configuration files
      # e.g dotfiles/config/mimeapps.list -> ~/.config/mimeapps.list
      configFile = discoverFiles ./dotfiles/config;

      # Symlink xdg data files
      # e.g dotfiles/local/foo/bar.bin -> ~/.local/share/foo/bar.bin
      dataFile = discoverFiles ./dotfiles/local;
  });

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # true is deprecated
    settings = let
      me = "kaizen";
      e621 = lib.fromHexString "0xe621";
    in {
      "*" = {
        # Default settings
        ServerAliveCountMax = 3;
        ServerAliveInterval = 20;
      };

      # Host-specific settings
      punyoracle = {
        HostName = "145.241.222.171";
        Port = e621;
        User = me;
      };
      rpi = {
        HostName = "192.168.1.50";
        Port = e621;
        User = me;
      };
    };
  };

  # Discover and add shell scripts automatically
  home.packages = (map
    (p: (pkgs.writeShellScriptBin
      (lib.removeSuffix ".sh" (builtins.baseNameOf p))
      (builtins.readFile p)
    ))
    (customLib.fs.listFiles ./text/shell-scripts)
  );

  # Environment variables set at login
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.shellAliases = {
    ffmpeg = "ffmpeg -hide_banner";
    ffprobe = "ffprobe -hide_banner";
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


  programs.vscodium = {
    enable = true;

    # Now if only I could banish the useless Default profile.
    # Sigh... Even here, Microsoft's poor decisions are inescapable.
    profiles.NixAndRust = {
      userSettings = {
        "git.openRepositoryInParentFolders" = "always";
        "git.ignoreLimitWarning" = true;
        "editor.inlayHints.fontSize" = 11;
      };
      extensions = with pkgs.vscode-extensions; [
        vadimcn.vscode-lldb
        rust-lang.rust-analyzer
        arrterian.nix-env-selector
        jnoortheen.nix-ide
      ];
    };
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
