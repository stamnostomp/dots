{
  description = "NixOS configuration for stamno";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Add NUR (Nix User Repository) - FIXED
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
      zen-browser,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # FIXED: Updated NUR overlay and improved structure
        overlays = [
          # Use the new NUR overlay syntax
          nur.overlays.default

          # Add our custom packages overlay
          (final: prev: {
            # Custom packages from our flake inputs
            everblush-gtk = everblush-gtk.packages.${system}.default;
            firefox-everblush-theme = firefox-everblush-theme.packages.${system}.default;
            doom-config = doom-config.packages.${system}.default;
            zen-browser = zen-browser.packages.${system}.default;
          })
        ];
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "libsoup-2.74.3"
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

            # Override hostname here to be explicit
            {
              networking.hostName = hostname;
            }

            # Make flake inputs available in NixOS
            {
              _module.args.inputs = inputs;
              _module.args.self = self;
            }

            # Include home-manager as a module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "backup";
                useUserPackages = true;
              };
              home-manager.extraSpecialArgs = {
                inherit inputs hostname;
              };
              # Import the user-specific configuration
              home-manager.users.stamno = import ./home/stamno;
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
        everblush-gtk = everblush-gtk.packages.${system}.default;
        firefox-theme = firefox-everblush-theme.packages.${system}.default;
        doom = doom-config.packages.${system}.default;
        zen-browser = zen-browser.packages.${system}.default;
      };

      # Add specific shells for each target
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt-rfc-style
            ripgrep
            fd
            jq
          ];

          shellHook = ''
            # Export NIX_SHELL to ensure Fish and Tide detect we're in a Nix shell
            export IN_NIX_SHELL=1
            export NIX_SHELL_NAME="nixos-config"

            # Create helpful aliases that explicitly specify the hostname
            alias ll="ls -la"
            alias rebuild-desktop="nixos-rebuild switch --flake .#desktop"
            alias rebuild-laptop="nixos-rebuild switch --flake .#laptop"
            alias check="nix flake check"

            # Show which configuration we're working with
            echo "NixOS Configuration Development Shell"
            echo "Available commands:"
            echo "  rebuild-desktop   - Rebuild the desktop configuration"
            echo "  rebuild-laptop    - Rebuild the laptop configuration"
            echo "  check             - Check the flake"

            # Execute fish with proper environment
            exec ${pkgs.fish}/bin/fish
          '';
        };

        # Add specific shells for each target
        desktop = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt-rfc-style
            ripgrep
            fd
            jq
          ];
          shellHook = ''
            export IN_NIX_SHELL=1
            export NIX_SHELL_NAME="nixos-desktop"
            echo "Building for: desktop"

            # Create helpful aliases
            alias ll="ls -la"
            alias rebuild="nixos-rebuild switch --flake .#desktop"
            alias check="nix flake check"

            exec ${pkgs.fish}/bin/fish
          '';
        };

        laptop = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt-rfc-style
            ripgrep
            fd
            jq
          ];
          shellHook = ''
            export IN_NIX_SHELL=1
            export NIX_SHELL_NAME="nixos-laptop"
            echo "Building for: laptop"

            # Create helpful aliases
            alias ll="ls -la"
            alias rebuild="nixos-rebuild switch --flake .#laptop"
            alias check="nix flake check"

            exec ${pkgs.fish}/bin/fish
          '';
        };
      };
    };
}
