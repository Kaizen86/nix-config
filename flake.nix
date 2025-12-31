{
  description = "Nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # For 'connor' host
    # Must use an older version because it hasn't been updated for 25.05 yet; attempting will cause rebuilds to fail due to its home-manager tweaks
    nixpkgs-droid.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
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

      customLib = import ./lib { inherit nixpkgs; };

      specialArgs = {
        inherit inputs customLib;
      };

    in {
      nixosConfigurations = builtins.listToAttrs
        (map
          (path: {
            name = builtins.baseNameOf path;
            value = nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              modules = modules ++ [ path ];
            };
          })
          # Automatically discover hosts in ./nixos/hosts
          (customLib.fs.listDirs ./nixos/hosts)
        );

      nixOnDroidConfigurations = {
        connor = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
           pkgs = import inputs.nixpkgs-droid { system = "aarch64-linux"; };
           extraSpecialArgs = { inherit customLib; };
           # I have attempted to include ./common for connor host but it just isn't happening. This makes sense; it's not a NixOS system.
           # I did at least manage to get its tweaked version of home-manager working for some user preferences. (the home.nix config import is in nix-on-droid/connor/configuration.nix)
           modules = [ ./nix-on-droid/connor ];
        };
      };

    };
}

