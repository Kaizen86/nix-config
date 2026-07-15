{ config, lib, pkgs, ... }:

let
  cfg = config.ham-radio;

in {
  options.ham-radio.enable = lib.mkEnableOption "HackRF+RTLSDR support";

  config = lib.mkIf cfg.enable {
    hardware.hackrf.enable = true; # Create udev rules for HackRF devices
    services.udev = {
      enable = true;
      packages = [ pkgs.rtl-sdr ];
    };
    boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
  };
}
