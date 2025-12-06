{ config, lib, pkgs, pkgs-old, ... }:
let
  bambu = config.programs.bambu-studio;
  orca = config.programs.orca-slicer;
in {
  options.programs = {
    bambu-studio.enable = lib.mkEnableOption "Install Bambu Studio";
    orca-slicer.enable = lib.mkEnableOption "Install Orca Slicer";
  };

  config.environment.systemPackages = 
    (if bambu.enable then [ pkgs.bambu-studio ] else []) ++
    (if orca.enable  then [ pkgs-old.orca-slicer ]  else []);

  config.networking.firewall = lib.mkIf (bambu.enable or orca.enable) {
    # Open necessary ports in the firewall for communicating with the printer.
    allowedTCPPorts = [
      1990 2021 990 123
    ] ++ lib.range 50000 50100;
    allowedUDPPorts = [
      123
    ];
    
  };
}
