{ pkgs, ... }:

{
  home-manager.users.kaizen = {
    # For some reason, one of my motherboard's USB hubs keeps timing out,
    # leading the kernel to assume it's died and stops trying to talk to it.
    # This means my mouse periodically stops working until I reload the xhci
    # kernel drivers. Until I figure out what's going on, xhci_reload will let
    # me reload the drivers to hopefully kick it back into life.
    home.packages = [
      (pkgs.writeShellScriptBin "xhci_reload" ''
        sudo 'bash' <<'END_SUDO'
          modules="xhci_hcd xhci_pci"
          modprobe -arv $modules
          modprobe -av ''${modules//_/-}
        END_SUDO
      '')
    ];

    # Mechanical keyboard is ANSI US layout
    programs.plasma.input.keyboard.layouts = [
      { layout = "us"; }
    ];

  };
}
