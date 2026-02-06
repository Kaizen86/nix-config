{ lib, ... }:

{
  # Allow Remote Play and Local Download by default
  programs.steam = {
    remotePlay.openFirewall                = lib.mkDefault true;
    localNetworkGameTransfers.openFirewall = lib.mkDefault true;
  };
}
