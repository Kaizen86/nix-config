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
    in
    {
    
      nixosConfigurations = {
          tower = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [ 
              ./hosts/tower/configuration.nix
              inputs.home-manager.nixosModules.default
            ];
          };
          laptop = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [ 
              ./hosts/laptop/configuration.nix
              inputs.home-manager.nixosModules.default
            ];
          };
          raspi = nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs;};
            modules = [ 
              ./hosts/raspi/configuration.nix
              inputs.home-manager.nixosModules.default
            ];
          };
      };
    };
}

