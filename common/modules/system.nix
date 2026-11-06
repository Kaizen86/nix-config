{ lib, ... }:

{
  # Make /tmp volatile
  boot.tmp.useTmpfs = true;

  # Enable all SysRq functions
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  # Show stars when typing password
  security.sudo.extraConfig = "Defaults pwfeedback";

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n = let
    locale = "en_GB.UTF-8";
  in {
    defaultLocale = locale;
    extraLocaleSettings = {
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
  };

  # Configure console keymap
  console.keyMap = lib.mkDefault "uk";

  # Enable networking service
  networking.networkmanager.enable = true;
}
