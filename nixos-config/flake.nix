{
  description = "NixOS configuration for stamno";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Add NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    # Package overrides and custom packages
    everblush-gtk = {
      url = "path:./pkgs/everblush-gtk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Firefox Everblush theme
    firefox-everblush-theme = {
      url = "path:./pkgs/firefox-everblush-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Doom Emacs configuration
    doom-config = {
      url = "path:./pkgs/doom-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      nur,
      everblush-gtk,
      firefox-everblush-theme,
      doom-config,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # Add NUR overlay
        overlays = [
          nur.overlay
          # Add our custom packages
          (final: prev: {
            inherit (everblush-gtk.packages.${system}) everblush-gtk;
            firefox-everblush-theme = firefox-everblush-theme.packages.${system}.default;
            doom-config = doom-config.packages.${system}.default;
          })
        ];
      };
      hostname = "desktop"; # Using the original hostname

      # Function to make system configuration with given hostname
      mkSystem =
        name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            hostname = name;
          };
          modules = [
            # Include the hardware configuration
            ./hosts/${name}/hardware.nix

            # Include the host-specific configuration
            ./hosts/${name}

            ./modules/system

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
                hostname = name;
              };
              # Import the user-specific configuration
              home-manager.users.stamno =
                { ... }:
                {
                  imports = [ ./home/stamno ];
                };
            }

            # Include Hyprland as a module
            {
              programs.hyprland = {
                enable = true;
                xwayland.enable = true;
              };
            }
          ];
        };
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        "${hostname}" = mkSystem hostname;
        # Add other hosts as needed
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        "stamno@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            hostname = hostname;
          };
          modules = [
            ./home/stamno
          ];
        };
      };

      packages.${system} = {
        inherit (everblush-gtk.packages.${system}) everblush-gtk;
        firefox-theme = firefox-everblush-theme.packages.${system}.default;
        doom = doom-config.packages.${system}.default;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          nixfmt
        ];

        shellHook = ''
          exec ${pkgs.fish}/bin/fish
        '';
      };
    };
}
