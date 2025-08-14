{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-on-droid, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
         ./common
         inputs.home-manager.nixosModules.default
       ];
    in
    {
    
      nixosConfigurations = {
        tower = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = modules ++ [ ./hosts/tower/configuration.nix ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = modules ++ [ ./hosts/laptop/configuration.nix ];
        };
      };

      nixOnDroidConfigurations = {
        connor = nix-on-droid.lib.nixOnDroidConfiguration {
           pkgs = import nixpkgs { system = "aarch64-linux"; };
           # I have attempted to include ./common and home-manager for connor host but it just isn't happening.
           # Too much is missing: nix.settings, nixpkgs.config, programs, environment.systemPackages, services, hardware, boot
           # And when I try to bring in home-manager, something in nix-on-droid complains that environment.pathsToLink doesn't exist.
           # I'm nowhere near experienced enough to go about fixing complex issues inside nix-on-droid!
           # This host will have to be set up completely independently... it kinda defeats the point :(
           modules = [ ./hosts/connor/configuration.nix ];
        };
      };

    };
}

