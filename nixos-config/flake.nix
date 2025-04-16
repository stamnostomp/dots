{
  description = "NixOS configuration for stamno";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Desktop environment
    hyprland.url = "github:hyprwm/Hyprland";

    # Package overrides and custom packages
    everblush-gtk = {
      url = "path:./pkgs/everblush-gtk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, everblush-gtk, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Function to make system configuration with given hostname
      mkSystem = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit hostname;
        };
        modules = [
          # Include the hardware configuration
          ./hosts/${hostname}/hardware.nix

          # Include the host-specific configuration
          ./hosts/${hostname}

          # Make flake inputs available in NixOS
          {
            _module.args.inputs = inputs;
            _module.args.self = self;
          }

          # Include home-manager as a module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit hostname;
            };
            # Import the user-specific configuration
            home-manager.users.stamno = import ./home/stamno;
          }

          # Include Hyprland as a module
          hyprland.nixosModules.default
          {
            programs.hyprland = {
              enable = true;
              xwayland.enable = true;
            };
          }
        ];
      };
    in {
      # NixOS configurations
      nixosConfigurations = {
        "${hostname}" = mkSystem "${hostname}";
        # Add other hosts as needed
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        "stamno@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            hostname = "${hostname}";
          };
          modules = [
            ./home/stamno
          ];
        };
      };

      # Make packages available for dependent flakes
      packages.${system} = {
        inherit (everblush-gtk.packages.${system}) everblush-gtk;
      };
    };
}
