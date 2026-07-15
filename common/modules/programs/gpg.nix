{ pkgs, ... }:

{
  #Enable gpg service and add the input tty environment variable
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt; # Graphical so Obsidian can prompt for password
    enableSSHSupport = true;
  };
  environment.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
}
