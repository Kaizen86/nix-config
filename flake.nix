{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
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
    };
}

