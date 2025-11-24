{ ... }:

let
  locale = "en_GB.UTF-8";
in {
  # Make /tmp volatile
  boot.tmp.useTmpfs = true;

  # Enable all SysRq functions
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable networking service
  networking.networkmanager.enable = true;
}
