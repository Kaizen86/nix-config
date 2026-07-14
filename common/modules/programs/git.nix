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
        # Credit to @supraerror on the Nix Cult Discord server lmaooo
        bs = ''!git commit -m "$(curl -s --connect-timeout 4 https://www.whatthecommit.com/index.txt || echo 'wip')"'';
      };

      # https://gist.github.com/BuonOmo/ce45b51d0cefe949fd0c536a4a60f000
      color.blame = {
        highlightRecent = "237, 20 month ago, 238, 19 month ago, 239, 18 month ago, 240, 17 month ago, 241, 16 month ago, 242, 15 month ago, 243, 14 month ago, 244, 13 month ago, 245, 12 month ago, 246, 11 month ago, 247, 10 month ago, 248, 9 month ago, 249, 8 month ago, 250, 7 month ago, 251, 6 month ago, 252, 5 month ago, 253, 4 month ago, 254, 3 month ago, 231, 2 month ago, 230, 1 month ago, 229, 3 weeks ago, 228, 2 weeks ago, 227, 1 week ago, 226";
      };
      blame = {
        coloring = "highlightRecent";
        date = "human";
      };
    };
  };
}
