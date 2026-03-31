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

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # For 'connor' host
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      # Override to not use 24.05
      inputs.home-manager.follows = "home-manager";
    };

  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      modules = [
        ./common

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = with inputs; [
            plasma-manager.homeModules.plasma-manager
          ];
        }
        inputs.nix-flatpak.nixosModules.nix-flatpak
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
          # Automatically discover host folders
          (customLib.fs.listDirs ./hosts)
        );

      nixOnDroidConfigurations = {
        connor = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
           pkgs = import inputs.nixpkgs { system = "aarch64-linux"; };
           extraSpecialArgs = { inherit customLib; };
           # I have attempted to include ./common for connor host but it just isn't happening. This makes sense; it's not a NixOS system.
           # I did at least manage to get its tweaked version of home-manager working for most user preferences. (the home.nix config import is in non-nixos/connor/configuration.nix)
           modules = [ ./non-nixos/connor ];
        };
      };

    };
}

