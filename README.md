# Directory structure

Note: this is subject to change as I find the best way to organise stuff

- [nixos] Applies to everything running NixOS
    - [common] Configurations shared across all hosts
        - [modules] Program/system configs
        - [user] Contains user account configs & home-manager
    - [hosts] Device-specific configurations
        - [laptop] terrible battery life but works well enough
        - [tower] My gaming PC :D
- [nix-on-droid] Sadly incompatible with NixOS configs :(
    - [connor] he's the Android sent by Cyberlife

<!-- Unsure what I'll do with the raspi. I haven't touched it for a long time... -->

# Installing on a new machine

These are my mental notes on how to add a new NixOS machine to this repo. If this doesn't make sense, I'm sorry >&#x2060;~&#x2060;<

- Clone the repo to /home/kaizen/nix-config
     ```bash
     nix-shell -p git vim
     git clone https://github.com/Kaizen86/nix-config
     cd nix-config
     ```
- Configure repo to use SSH
     ```bash
     git remote set-url origin ssh://git@github.com/Kaizen86/nix-config
     ```
- Generate and add [SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) & [GPG](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) keys to Github
- Move `/etc/nixos/` contents to `nixos/hosts/newhost`
     - (replace `newhost` with some unique identifier, of course)
- Symlink `/etc/nixos` --> `/home/kaizen/nix-config`
     ```bash
     sudo ln -sv /home/kaizen/nix-config /etc/nixos
     ```
- Edit `hosts/newhost/configuration.nix` to set hostname to `newhost` (important!)
- Track changes with `git add .` (otherwise `nixos/hosts/newhost` won't be in the Nix store)
- Run ./rebuild.sh
- If that worked, commit changes and push:
     ```bash
     git commit -m "Add new host newhost"
     git push
     ```

# Workflow
When making a change to the config, follow this order:
1. `git add` any new files to track them
2. Run either `./rebuild.sh` or `nix flake check` to make sure the change works
3. Once you're happy with a change, `git commit` it
4. Repeat for however many changes you're making
5. Once you've run `./rebuild.sh` and are entirely happy none of the commits need amending, `git push` them so all devices can use the new config.

