# Stuff in here shouldn't need to be changed often.
# Be careful when you do change something, of course.
{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Disable second monitor during boot to un-fuck plymouth
  # This *technically* works, but the second monitor is permanently disabled lol
  #boot.kernelParams = [ "video=HDMI-A-1:d" ];

  # Forward kernel and grub messages to the serial port
  # Warning: enabling this will break plymouth!
  #boot.kernelParams = [ "console=ttyS0,115200n8" ];
  /*
  boot.loader.grub.extraConfig = "
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  ";
  */

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/be2af937-eeb5-4b79-8132-3b74cc0145f2";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8C26-5DE1";
      fsType = "vfat";
    };

  fileSystems."/run/media/kaizen/Nautilus" =
    { device = "/dev/disk/by-label/Nautilus";
      fsType = "ext4";
      options = [
        "users" # Allow any user to mount/unmount
        "nofail" # Don't enter Emergency Mode if this drive is missing
        "exec" # Allow executing programs on this drive
      ];
    };

  fileSystems."/run/media/kaizen/Cuttlefish" =
    { device = "/dev/disk/by-label/Cuttlefish";
      fsType = "ext4";
      options = [
        "users" # Allow any user to mount/unmount
        "nofail" # Don't enter Emergency Mode if this drive is missing
        "exec" # Allow executing programs on this drive
      ];
    };

  # This system has 64GB of RAM, so adding swap isn't really useful.
  # If we run out of memory, just let the OOM reaper do its job lol
  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
