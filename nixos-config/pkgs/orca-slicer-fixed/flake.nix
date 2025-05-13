{
  description = "Orca Slicer AppImage with Wayland/NVIDIA fixes and WebKit dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Download the latest AppImage for Orca Slicer
        orcaSlicerAppImage = pkgs.fetchurl {
          url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v2.3.0/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.3.0.AppImage";
          sha256 = "0vp1k98sgzmk0bsnrfxxvxmkmrfvq0flzhwgl7fdkkn8y31dmhjg"; # Replace with the actual hash if this doesn't work
          executable = true;
        };

        # Create an appimage run wrapper with the needed dependencies
        customAppimageRun = pkgs.writeShellScriptBin "custom-appimage-run" ''
          #!/usr/bin/env bash

          # Create a temporary directory to extract the AppImage
          TEMP_DIR="$(mktemp -d)"

          # Create a new FHS environment with all required dependencies
          ${
            pkgs.buildFHSUserEnv {
              name = "orca-slicer-fhs";
              targetPkgs =
                pkgs: with pkgs; [
                  webkitgtk
                  cairo
                  gdk-pixbuf
                  glib
                  gtk3
                  pango
                  xorg.libXtst
                  xorg.libX11
                  xorg.libXi
                  xorg.libXcursor
                  xorg.libXdamage
                  xorg.libXrandr
                  xorg.libXcomposite
                  xorg.libXext
                  xorg.libXfixes
                  # More libraries that might be needed by the AppImage
                  alsa-Lib
                  at-spi2-atk
                  at-spi2-core
                  atk
                  cups
                  dbus
                  expat
                  fontconfig
                  freetype
                  libdrm
                  libGL
                  libnotify
                  libuuid
                  libxkbcommon
                  nspr
                  nss
                  sqlite
                  systemd
                  zlib
                  # Add both versions of WebKit
                  webkitgtk_4_0
                  webkitgtk_4_1
                  webkitgtk
                ];
              runScript = "$@";
            }
          }/bin/orca-slicer-fhs "${orcaSlicerAppImage}" "$@"
        '';

        # Create a wrapper script that uses the custom appimage-run
        orcaSlicerWrapper = pkgs.writeShellScriptBin "orca-slicer" ''
          #!/usr/bin/env bash

          # Detect if running on Wayland
          if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            echo "Detected Wayland session"

            # Check if NVIDIA GPU is present
            if command -v nvidia-smi &> /dev/null; then
              echo "Detected NVIDIA GPU, applying Zink compatibility fixes"

              # Use Zink to bypass NVIDIA's OpenGL implementation with our custom appimage run
              exec env \
                __GLX_VENDOR_LIBRARY_NAME=mesa \
                __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
                MESA_LOADER_DRIVER_OVERRIDE=zink \
                GALLIUM_DRIVER=zink \
                WEBKIT_DISABLE_DMABUF_RENDERER=1 \
                WEBKIT_FORCE_COMPOSITING_MODE=1 \
                WEBKIT_DISABLE_COMPOSITING_MODE=1 \
                WEBKIT_DISABLE_GPU_PROCESS=1 \
                WEBKIT_GST_DISABLE_HW_ACCEL=1 \
                GTK_CELL_LAYOUT_IGNORE_CONFLICTS=1 \
                GTK_IGNORE_ASSERT_FAILURES=1 \
                NO_AT_BRIDGE=1 \
                "${customAppimageRun}/bin/custom-appimage-run"
            else
              echo "Running on Wayland with non-NVIDIA GPU"

              # Use standard Wayland environment variables with our custom appimage run
              exec env \
                WEBKIT_DISABLE_DMABUF_RENDERER=1 \
                GTK_CELL_LAYOUT_IGNORE_CONFLICTS=1 \
                GTK_IGNORE_ASSERT_FAILURES=1 \
                "${customAppimageRun}/bin/custom-appimage-run"
            fi
          else
            echo "Running on X11"

            # Standard environment for X11 with our custom appimage run
            exec env \
              GTK_CELL_LAYOUT_IGNORE_CONFLICTS=1 \
              GTK_IGNORE_ASSERT_FAILURES=1 \
              WEBKIT_DISABLE_DMABUF_RENDERER=1 \
              "${customAppimageRun}/bin/custom-appimage-run"
          fi
        '';

        # Create a desktop entry
        desktopItem = pkgs.makeDesktopItem {
          name = "orca-slicer";
          desktopName = "Orca Slicer";
          comment = "G-code generator for 3D printers with Wayland/NVIDIA fixes";
          exec = "${orcaSlicerWrapper}/bin/orca-slicer %F";
          icon = "orca-slicer";
          categories = [
            "Graphics"
            "3DGraphics"
            "Engineering"
          ];
          mimeTypes = [
            "model/stl"
            "application/vnd.ms-3mfdocument"
            "application/prs.wavefront-obj"
            "application/x-amf"
          ];
        };

        # Create a setup script
        setupScript = pkgs.writeShellScriptBin "orca-slicer-setup" ''
          #!/bin/bash

          echo "Setting up Orca Slicer GTK and WebKit configuration..."

          # Create GTK settings directory
          mkdir -p "$HOME/.config/gtk-3.0"

          # Create a basic settings.ini file
          cat > "$HOME/.config/gtk-3.0/settings.ini" << EOF
          [Settings]
          gtk-theme-name=Adwaita
          gtk-icon-theme-name=Adwaita
          gtk-font-name=Sans 10
          gtk-cursor-theme-name=Adwaita
          gtk-cursor-theme-size=24
          gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
          gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
          gtk-button-images=0
          gtk-menu-images=0
          gtk-enable-event-sounds=0
          gtk-enable-input-feedback-sounds=0
          gtk-xft-antialias=1
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintslight
          gtk-cell-layout-fixed-alignment=1
          EOF

          # Create WebKit directory
          mkdir -p "$HOME/.config/webkit"

          # Create WebKit preferences
          cat > "$HOME/.config/webkit/prefs.ini" << EOF
          [WebKit]
          HardwareAccelerationPolicy=0
          EnableDeveloperExtras=false
          EOF

          echo "Setup complete."
        '';

        # Extract Orca Slicer icon (using a precomputed path since extraction with AppImage is complex)
        orcaSlicerIcon = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/SoftFever/OrcaSlicer/master/resources/icons/OrcaSlicer_128px.png";
          sha256 = "0i8qpxv6qpz7pj5avnvfrh1mr01gvmylxb6if6rm3kgw0xx8qviz"; # Replace with the actual hash
        };

        iconDerivation = pkgs.runCommand "orca-slicer-icon" { } ''
          mkdir -p $out/share/icons/hicolor/128x128/apps
          cp ${orcaSlicerIcon} $out/share/icons/hicolor/128x128/apps/orca-slicer.png
        '';

        # Create a full package with the wrapper, desktop entry, and icon
        orcaSlicerFull = pkgs.symlinkJoin {
          name = "orca-slicer-full";
          paths = [
            orcaSlicerWrapper
            customAppimageRun
            desktopItem
            iconDerivation
            setupScript
          ];

          buildInputs = [ pkgs.makeWrapper ];

          # Ensure dependencies are available in the PATH
          postBuild = ''
            wrapProgram $out/bin/orca-slicer \
              --prefix PATH : ${
                pkgs.lib.makeBinPath [
                  pkgs.mesa
                  pkgs.vulkan-loader
                  pkgs.vulkan-tools
                  pkgs.gnome.adwaita-icon-theme
                  pkgs.gtk3
                ]
              }
          '';
        };

      in
      {
        packages = {
          default = orcaSlicerFull;
          orca-slicer = orcaSlicerWrapper;
          custom-appimage-run = customAppimageRun;
          orca-slicer-setup = setupScript;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = orcaSlicerWrapper;
            name = "orca-slicer";
          };

          setup = flake-utils.lib.mkApp {
            drv = setupScript;
            name = "orca-slicer-setup";
          };
        };

        # NixOS module
        nixosModules.default =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          with lib;
          let
            cfg = config.programs.orca-slicer;
          in
          {
            options.programs.orca-slicer = {
              enable = mkEnableOption "Enable Orca Slicer with Wayland/NVIDIA fixes";
            };

            config = mkIf cfg.enable {
              environment.systemPackages = [
                self.packages.${system}.default
              ];

              # Enable required services and drivers
              programs.dconf.enable = true;
              fonts.fontconfig.enable = true;

              # Add extra drivers for Vulkan/Zink
              hardware.opengl = {
                enable = true;
                driSupport = true;
                driSupport32Bit = true;
              };
            };
          };

        # Home-manager module
        homeManagerModules.default =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          with lib;
          let
            cfg = config.programs.orca-slicer;
          in
          {
            options.programs.orca-slicer = {
              enable = mkEnableOption "Enable Orca Slicer with Wayland/NVIDIA fixes";
            };

            config = mkIf cfg.enable {
              home.packages = [
                self.packages.${system}.default
              ];

              # Run setup script during activation
              home.activation.setupOrcaSlicer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                $DRY_RUN_CMD ${self.packages.${system}.orca-slicer-setup}/bin/orca-slicer-setup
              '';

              # Add GTK configuration
              gtk = {
                enable = true;
                theme = {
                  name = "Adwaita";
                  package = pkgs.gnome.gnome-themes-extra;
                };
                iconTheme = {
                  name = "Adwaita";
                  package = pkgs.gnome.adwaita-icon-theme;
                };
              };
            };
          };
      }
    );
}
