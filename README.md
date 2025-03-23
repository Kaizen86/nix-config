# Directory structure

Note: this is subject to change as I find the best way to organise stuff

- [common] Configurations shared across all hosts
     - [modules] Organised program/system configs
     - [user] Contains user account configs & home-manager
- [hosts] Device-specific configurations
     - [tower] Gaming PC :D
     - [laptop] kind of crap but it works fine
     - [connor] he's the Android sent by Cyberlife
     - [raspi] dnsmasq server (eventually™)

Note: raspi exists on a separate branch for now

# Installing on a new machine

These are my mental notes on how to add a new NixOS machine to this repo. If this doesn't make sense, I'm sorry >~<

- Clone the repo to /home/kaizen/nix-config
- Edit .git/config origin to use SSH login
- Generate and add [SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)/[GPG](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) keys to Github
- Move `/etc/nixos/` contents to `hosts/newhost`
- Symlink `/etc/nixos` --> `/home/kaizen/nix-config`
- Add new entry to flake.nix
- Run ./rebuild.sh
- If that worked, commit changes and push
