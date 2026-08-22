{ config, lib, pkgs, ... }:

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
    cargo rustc # Reduce download size of flakes
  ]);
}

