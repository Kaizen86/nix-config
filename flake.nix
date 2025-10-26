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

      customLib = rec {
        readDirByType = (type: path:
          map
          # 4. Convert names to full path: [ /a/b/c/bar ];
          (n: nixpkgs.lib.path.append path n)
          # 3. Get the file names as a list: [ "bar" ]
          (builtins.attrNames
            # 2. Select by desired type: { "bar" = "regular"; }
            (nixpkgs.lib.filterAttrs
              (n: v: v == type)
              # 1. Get files/directories in some path: { "foo" = "directory"; "bar" = "regular"; }
              (builtins.readDir path)
            )
          )
        );

        readDirByTypeExcluding = (type: path: excluding:
          map
          # 5. Convert names to full path: [ /a/b/c/bar ];
          (n: nixpkgs.lib.path.append path n)
          # 4. Filter excluded names
          (builtins.filter
            (n: builtins.any (i: n!=i) excluding)
            # 3. Get the file names as a list: [ "bar" "baz" ]
            (builtins.attrNames
              # 2. Select by desired type: { "bar" = "regular"; "baz" = "regular"; }
              (nixpkgs.lib.filterAttrs
                (n: v: v == type)
                # 1. Get files/directories in some path: { "foo" = "directory"; "bar" = "regular"; "baz" = "regular"; }
                (builtins.readDir path)
              )
            )
          )
        );

        # Shortcuts for files/directories
        listFiles = readDirByType "regular";
        listDirs  = readDirByType "directory";
        listFilesExcluding = readDirByTypeExcluding "regular";
        listDirsExcluding  = readDirByTypeExcluding "directory";
      };

      # Automatically discover hosts in ./nixos/hosts
      nixos_hosts = customLib.listDirs ./nixos/hosts;

    in {
      nixosConfigurations = builtins.listToAttrs
        (map
          (path: {
            name = builtins.baseNameOf path;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs; inherit customLib; };
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

