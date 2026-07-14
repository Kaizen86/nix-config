{ config, lib, ... }:

let
  cfg = config.services.nix-serve.nginx;

in {
  options.services.nix-serve.nginx = {
    enable = lib.mkEnableOption "Nginx server automatic setup";

    secretKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Path to self-signed private key";
	  default = null;
    };
  };

  config = {
    # Note: You don't need to give nix-serve ownership of the file because systemd reads it.
    services.nix-serve.secretKeyFile = cfg.secretKeyFile;

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
