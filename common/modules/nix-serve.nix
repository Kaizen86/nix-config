{ config, lib, ... }:

let
  cfg = config.services.nix-serve.nginx;

in {
  options.services.nix-serve.nginx = {
    enable = lib.mkEnableOption "Nginx server automatic setup";
  };

  config = {
    services.nginx = lib.mkIf cfg.enable {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "_" = {
          locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
        };
      };
    };
  };

}
