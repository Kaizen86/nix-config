{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # For 'connor' host
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
        ./nixos/common

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
        }
      ];

    nixos_hosts_path = ./nixos/hosts;
    # Automatically discover hosts in ./nixos/hosts
    # Note: This will also include any files, which could be used for single-file hosts (but why would you??)
    nixos_hosts = map
      # 3. Convert names into a path: [ /home/user/somewhere/foo ]
      (dir: nixpkgs.lib.path.append nixos_hosts_path dir )
      # 2. Get names of those directories: [ "foo" ]
      (builtins.attrNames
        # 1. Get files/directories in cwd: { "foo" = "directory"; }
        (builtins.readDir nixos_hosts_path)
      );

    in {
      nixosConfigurations = builtins.listToAttrs
        (map
          (path: {
            name = builtins.baseNameOf path;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs; };
              modules = modules ++ [ path ];
            };
          })
          nixos_hosts
        );

      nixOnDroidConfigurations = {
        connor = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
           pkgs = import nixpkgs { system = "aarch64-linux"; };
           # I have attempted to include ./common and home-manager for connor host but it just isn't happening.
           # Too much is missing: nix.settings, nixpkgs.config, programs, environment.systemPackages, services, hardware, boot
           # And when I try to bring in home-manager, something in nix-on-droid complains that environment.pathsToLink doesn't exist.
           # I'm nowhere near experienced enough to go about fixing complex issues inside nix-on-droid!
           # This host will have to be set up completely independently... it kinda defeats the point :(
           modules = [ ./nix-on-droid/connor ];
        };
      };

    };
}

