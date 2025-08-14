{ lib, ... }:

{
  config.programs.git = {
    enable = lib.mkDefault true;
    # Default configuration, override as appropriate
    config = {
      user = {
        name = "Kaizen86";
        email = "danielbridgewater87@gmail.com";
        #user.signingkey should be specified by each host individually
      };
      commit.gpgsign = true; # Use GPG by default

      core.autoclrf = "input"; # Converts CRLF to LF when pulling

      alias = {
        tree = "log --oneline --all --graph";
      };
    };
  };
}
