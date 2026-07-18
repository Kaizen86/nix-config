{ lib, ... }:

{
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
}
