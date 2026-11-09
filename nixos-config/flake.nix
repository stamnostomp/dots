{
  description = "NixOS configuration for stamno";

  nixConfig = {
    extra-substituters = [ "https://deadlock-mod-manager.cachix.org" ];
    extra-trusted-public-keys = [
      "deadlock-mod-manager.cachix.org-1:wUjtzL6yN2i9zTq1YrXHBr0mx3LP7tBGsosk3N+/A/M="
    ];
  };

  inputs = {
    # Core dependencies
    # NOTE: nixos-unstable-small has almost no binary cache lag coverage.
    # Fresh revs (e.g. 7a1ebac from today) force multi-hour source builds of
    # freecad/ifcopenshell. Use full nixos-unstable for cache hits.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    # Pulsar gaming mouse configuration tool (GUI + CLI)
    pulsar-mouse-linux = {
      url = "github:packerlschupfer/pulsar-mouse-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser (Firefox-based)
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Deadlock Mod Manager pinned to the latest upstream release tag.
    # Do NOT follow `main` here: the hash-bot commits to main several times a
    # day and those HEADs are usually NOT on their Cachix cache, which forces
    # multi-hour local rebuilds. Pin the release tag instead and bump it with
    # the `update-dmm` alias in the dev shell when a new release comes out.
    deadlock-mod-manager = {
      url = "github:deadlock-mod-manager/deadlock-mod-manager/v2.3.0";
    };

    # Minimal RemoteDesktop portal for Hyprland. xdg-desktop-portal-hyprland
    # does not implement org.freedesktop.portal.RemoteDesktop, so KDE Connect
    # remote input fails with "RemoteDesktop portal not authenticated".
    hyprland-remote-portal = {
      url = "github:TheWolfStreet/hyprland-remote-portal";
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
      pulsar-mouse-linux,
      zen-browser,
      deadlock-mod-manager,
      hyprland-remote-portal,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        # Use the new NUR overlay syntax
        nur.overlays.default

        # Pulsar mouse tool (provides pkgs.pulsar-mouse-linux)
        pulsar-mouse-linux.overlays.default

        # Add our custom packages overlay
        (final: prev: {
          # Custom packages from our flake inputs
          everblush-gtk = everblush-gtk.packages.${prev.stdenv.hostPlatform.system}.default;
          firefox-everblush-theme =
            firefox-everblush-theme.packages.${prev.stdenv.hostPlatform.system}.default;

          # Vendored from nixpkgs master commit c399e1b ("opencode: fix hash"):
          # the 2.2.5 node_modules hash changed upstream after our pinned
          # nixpkgs snapshot (2026-11-03.1d06008) was cut, breaking rebuilds.
          # Remove this override once nixpkgs is bumped past c399e1b.
          opencode = final.callPackage ./pkgs/opencode/package.nix { };
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
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
          specialArgs = {
            inherit inputs hostname;
          };
          modules = hostModules ++ [
            # System modules
            ./modules/system

            # Override hostname here to be explicit
            {
              nixpkgs.hostPlatform = system;
              networking.hostName = hostname;
            }

            # Make flake inputs available in NixOS
            {
              _module.args.inputs = inputs;
              _module.args.self = self;
            }

            # Custom package overlays (also used by the standalone homeConfigurations pkgs above)
            {
              nixpkgs.overlays = overlays;
              nix.settings = {
                extra-substituters = [ "https://deadlock-mod-manager.cachix.org" ];
                extra-trusted-public-keys = [
                  "deadlock-mod-manager.cachix.org-1:wUjtzL6yN2i9zTq1YrXHBr0mx3LP7tBGsosk3N+/A/M="
                ];
              };
            }

            # Zen Browser (from wiki.nixos.org/wiki/Zen_Browser, System setup)
            {
              environment.systemPackages = [
                inputs.zen-browser.packages."${system}".default
              ];
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
                # UWSM wraps the session so it sets up XDG/Wayland env, the
                # D-Bus activation environment, and graphical-session.target
                # (xdg-desktop-portal). Launching bare `Hyprland` from the
                # display manager left these unset, breaking portal-dependent apps.
                withUWSM = true;
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
        # Direct handle on the upstream flake package (see update-dmm alias)
        deadlock-mod-manager = deadlock-mod-manager.packages.${system}.default;
      };

      # Add specific shells for each target
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt
            ripgrep
            fd
            jq
            gh
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
            # Bump the deadlock-mod-manager input to the newest upstream release
            alias update-dmm='tag=$(gh release list -R deadlock-mod-manager/deadlock-mod-manager --limit 1 --json tagName --jq ".[0].tagName"); sed -i "s|deadlock-mod-manager/v[0-9.]*\"|deadlock-mod-manager/$tag\"|" flake.nix && nix flake lock --update deadlock-mod-manager && echo "deadlock-mod-manager bumped to $tag"'

            # Show which configuration we're working with
            echo "NixOS Configuration Development Shell"
            echo "Available commands:"
            echo "  rebuild-desktop   - Rebuild the desktop configuration"
            echo "  rebuild-laptop    - Rebuild the laptop configuration"
            echo "  check             - Check the flake"
            echo "  update-dmm        - Bump deadlock-mod-manager to latest release"

            # Execute fish with proper environment
            exec ${pkgs.fish}/bin/fish
          '';
        };

        # Add specific shells for each target
        desktop = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt
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
            nixfmt
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
