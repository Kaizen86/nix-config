{ config, lib, pkgs, newPkgs, ... }:

{
  # Regular import so it can read our packageSets
  # Unfortunately this incurs a bunch of shitcode...
  imports = [ ../../common/packages.nix ];

  # Hack to catch the result so I can rename it
  options.environment.systemPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    description = "Glue between nix-on-droid and common/packages.nix";
    default = [];
    visible = false;
  };
  # Another hack to catch some flatpak configurationo
  # TODO should enable them in common/default.nix
  options.programs = lib.mkOption {};


  # Restrict what should be installed on this device
  # Finally, some normal fucking code lmao
  config.packageSets = {
    desktopApplications.enable = false;
    fontsAndCursors.enable = false;
    systemTools.enable = false;
  };

  # Rebind the output to the correct variable
  config.environment.packages = config.environment.systemPackages
  ++ (with pkgs; [
    # Anything extra goes here
    ncurses # Provides clear and reset commands
  ]) ++ map lib.hiPrio (with newPkgs; [
    # Things which simply must be up-to-date
    cargo rustc # Reduce download size of flakes
    yt-dlp # Websites are a moving target
  ]);
}

