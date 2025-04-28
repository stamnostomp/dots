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

      # Function to make system configuration with given hostname
      mkSystem =
        hostname:
        let
          # Define modules based on hostname
          hostModules =
            if hostname == "laptop" then
              [
                # Include ThinkPad T480 module - it's similar to T470
                nixos-hardware.nixosModules.lenovo-thinkpad-t480
                # Add basic laptop configs
                ./hosts/${hostname}/hardware.nix
                ./hosts/${hostname}
              ]
            else
              [
                # Desktop modules
                ./hosts/${hostname}/hardware.nix
                ./hosts/${hostname}
              ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs hostname;
          };
          modules = hostModules ++ [
            # System modules
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
                inherit inputs hostname;
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
        "desktop" = mkSystem "desktop";
        "laptop" = mkSystem "laptop";
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        "stamno@desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            hostname = "desktop";
          };
          modules = [
            ./home/stamno
          ];
        };

        "stamno@laptop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            hostname = "laptop";
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
