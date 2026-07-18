{
  description = "Nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-droid";
      # Override to not use 24.05
      inputs.home-manager.follows = "home-manager-droid";
    };
    # Temporary fix until nix-on-droid merges PR #529 (proot-termux update)
    # See: https://github.com/nix-community/nix-on-droid/issues/495
    nixpkgs-droid.url = "github:NixOS/nixpkgs/5d874ac46894c896119bce68e758e9e80bdb28f1";
    home-manager-droid = {
      url = "github:nix-community/home-manager/4de84265d7ec7634a69ba75028696d74de9a44a7";
      inputs.nixpkgs.follows = "nixpkgs-droid";
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

      lib = nixpkgs.lib;
      customLib = import ./lib { inherit lib; };

    in {
      nixosConfigurations = import ./hosts {
        inherit inputs modules lib customLib;
      };

      nixOnDroidConfigurations = {
        connor = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
           pkgs = import inputs.nixpkgs-droid { system = "aarch64-linux"; };
           extraSpecialArgs = { inherit customLib; };
           # I have attempted to include ./common for connor host but it just isn't happening. This makes sense; it's not a NixOS system.
           # I did at least manage to get its tweaked version of home-manager working for most user preferences. (the home.nix config import is in non-nixos/connor/configuration.nix)
           modules = [ ./non-nixos/connor ];
        };
      };

    };
}

