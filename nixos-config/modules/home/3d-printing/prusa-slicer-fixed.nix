# modules/home/3d-printing/prusa-slicer-fixed.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Create an FHS environment specifically for PrusaSlicer
  prusaSlicerFHS = pkgs.buildFHSEnv {
    name = "prusa-slicer-fhs";
    targetPkgs =
      pkgs: with pkgs; [
        prusa-slicer
        # Basic GTK dependencies
        gtk3
        glib
        pango
        cairo
        gdk-pixbuf
        atk
        # OpenGL and graphics libraries
        libGL
        libGLU
        xorg.libX11
        xorg.libXi
        xorg.libXcursor
        xorg.libXdmcp
        xorg.libXext
        xorg.libXfixes
        xorg.libXrender
        xorg.libXtst
        xorg.libXinerama
        xorg.libxcb
        # Additional system libraries
        zlib
        libpng
        libjpeg
        expat
        fontconfig
        freetype
        # Prebuilt dependencies from Adwaita theme
        pkgs.adwaita-icon-theme
        # Common system libraries
        curl
        openssl
        dbus
        cups
        libcap
      ];
    # Create a simple run script
    runScript = ''
      exec prusa-slicer --no-remote-check --no-check-system-version "$@"
    '';
    profile = ''
      # Set GTK-specific environment variables
      export GDK_BACKEND=x11
      export GTK_THEME=Adwaita:light
      export GTK_CSD=0
      export GTK_CELL_LAYOUT_IGNORE_CONFLICTS=1
      export GTK_IGNORE_ASSERT_FAILURES=1
      export NO_AT_BRIDGE=1
      export G_DEBUG=fatal-criticals
      # Make PrusaSlicer run offline to avoid API issues
      export PRUSASLICER_OFFLINE=1
      # OpenGL configuration
      export LIBGL_DEBUG=verbose
      export MESA_DEBUG=1
      # Use software rendering as fallback
      export LIBGL_ALWAYS_SOFTWARE=1
    '';
  };

  # Create a wrapper script that runs PrusaSlicer in the FHS environment
  prusaSlicerWrapper = pkgs.writeScriptBin "prusa-slicer-fixed" ''
    #!/usr/bin/env bash

    # Check if there's a stuck process
    if pgrep -f "prusa-slicer" > /dev/null; then
      echo "Warning: PrusaSlicer process already running. Killing it..."
      pkill -9 -f "prusa-slicer"
      sleep 1
    fi

    # Run PrusaSlicer in the FHS environment
    ${prusaSlicerFHS}/bin/prusa-slicer-fhs "$@"
  '';

  # Create a desktop entry that uses our wrapper
  desktopItem = pkgs.makeDesktopItem {
    name = "prusa-slicer-fixed";
    desktopName = "PrusaSlicer (Fixed)";
    genericName = "3D Printing Slicer";
    comment = "G-code generator for 3D printers (with FHS environment)";
    exec = "${prusaSlicerWrapper}/bin/prusa-slicer-fixed %F";
    icon = "${pkgs.prusa-slicer}/share/pixmaps/PrusaSlicer.png";
    categories = [
      "Graphics"
      "3DGraphics"
    ];
    mimeTypes = [
      "model/stl"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
    ];
  };

  # Create a complete package with both the wrapper and desktop entry
  prusaSlicerFixed = pkgs.symlinkJoin {
    name = "prusa-slicer-fixed";
    paths = [
      prusaSlicerWrapper
      desktopItem
    ];
  };

  # Create a script to reset PrusaSlicer configuration
  resetScript = pkgs.writeScriptBin "reset-prusa-slicer" ''
    #!/usr/bin/env bash

    echo "This will reset your PrusaSlicer configuration. Are you sure? (y/n)"
    read confirm

    if [ "$confirm" != "y" ]; then
      echo "Operation cancelled."
      exit 0
    fi

    # Kill any running instances
    pkill -9 -f "prusa-slicer" || true

    # Create backup
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="$HOME/prusa-slicer-backup-$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"

    # Backup config files if they exist
    if [ -d "$HOME/.config/PrusaSlicer" ]; then
      cp -r "$HOME/.config/PrusaSlicer" "$BACKUP_DIR/"
      echo "Created backup in $BACKUP_DIR"
    fi

    # Reset configuration
    rm -rf "$HOME/.config/PrusaSlicer"

    # Create clean configuration directory
    mkdir -p "$HOME/.config/PrusaSlicer"

    echo "PrusaSlicer configuration has been reset."
    echo "Backup saved to: $BACKUP_DIR"
    echo "Run 'prusa-slicer-fixed' to start with fresh settings."
  '';
in
{
  # Add our fixed PrusaSlicer and reset script to home packages
  home.packages = [
    prusaSlicerFixed
    resetScript
  ];

  # Add a script to kill any stuck PrusaSlicer processes
  home.file.".local/bin/kill-prusaslicer" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      echo "Killing all PrusaSlicer processes..."
      pkill -9 -f "prusa-slicer"
      echo "Done."
    '';
  };

  # Create a README file with troubleshooting instructions
  home.file.".local/share/prusa-slicer-help.txt" = {
    text = ''
      =================================
      PrusaSlicer on NixOS - Help Guide
      =================================

      If you're experiencing crashes or issues with PrusaSlicer:

      1. Run it from the terminal with:
         $ prusa-slicer-fixed

      2. If it crashes, try resetting the configuration:
         $ reset-prusa-slicer

      3. If it's stuck or frozen:
         $ kill-prusaslicer

      4. Common issues:
         - Connecting to physical printers: This might not work due to networking restrictions
         - Checking for updates: Disabled to prevent crashes
         - Some dialogs may appear different due to the FHS environment

      5. If all else fails, try using SuperSlicer or OrcaSlicer as alternatives.

      Good luck with your 3D printing!
    '';
  };
}
