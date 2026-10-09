{ config, lib, nixosConfig, ... }:

let
  # Check whether a particular package is installed on the system
  have = p: builtins.elem p nixosConfig.environment.systemPackages;
  sets = nixosConfig.packageSets;

  # See /run/current-system/sw/share/applications for a list of IDs
  # key:value is id:pinned
  # In a list so order is retained
  applicationOrder = [
    { "preferred://filemanager" = true; }
    # Supposed to work but doesn't?
    # https://discuss.kde.org/t/any-documentation-for-preferred-uri-schema/30689/5
    #{ "preferred://terminal" = true; }
    { "applications:org.kde.konsole.desktop" = true; }
    { "preferred://browser" = true; }
    { "applications:org.kde.kate.desktop" = sets.desktopApplications.enable; }
    { "applications:discord.desktop" = sets.desktopApplications.enable; }
    { "applications:steam.desktop" = nixosConfig.programs.steam.enable; }
    { "applications:org.telegram.desktop.desktop" = sets.desktopApplications.enable; }
    { "applications:obsidian.desktop" = sets.desktopApplications.enable; }
  ];

  # List of installed app IDs
  pinnedApplications = builtins.concatLists (
    map
      (i: lib.attrNames (
	    lib.filterAttrs (n: v: v) i)
      )
      applicationOrder
  );

  mkDefault = lib.mkDefault;
in {
  # Adapted from github:nix-community/plasma-manager/examples/home.nix
  programs.plasma = {
    enable = true;

    workspace = {
      colorScheme = "BreezeDark";
      # Use Posy's cursors (installed via environment.systemPackages)
      cursor = {
        theme = "Posy_Cursor_Black";
        size = mkDefault 32; # Normal size, please
      };

      # Select items when single-clicking, not open
      # Windows behaviour
      clickItemTo = "select";
    };
    session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";

    # Meta+Shift+K
    input.keyboard.layouts = mkDefault [
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
            # Declaratively pin applications, yEAAA!!
            iconTasks.launchers = pinnedApplications;
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


  programs.dolphin = {
    enable = true;

    interface = {
      foldersAndTabs = {
        startupLocation = config.home.homeDirectory;
        launchInNewTab = true;

        window.fullPath = true;
        tabs.openAtEnd = true;
        splitView.close = "inactive";
      };

      panels.information.dateFormat = "short";

      bars = {
        status = "full";
        location = {
          editable = true;
          showFullPath = true;
        };
      };
    };

    view = {
      general = {
        browseArchives = true;
        dragOpenFolders = true;
        hoverForInfo = true;
        backgroundDoubleClick.action = "showHiddenFiles";
      };
      contentDisplay = {
        relativeDates = true;
        permissionsStyle = "combined";
      };
    };
  };
}
