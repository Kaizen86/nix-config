{ lib, ... }:

{
  # Activate Bluetooth on boot
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
  };
}
