{ ... }:

{
  # Make /tmp volatile
  boot.tmp.useTmpfs = true;

  # Enable all SysRq functions
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";
 
  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
 
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
 
  # Configure console keymap
  console.keyMap = "uk";

  # Enable networking service
  networking.networkmanager.enable = true;
}
