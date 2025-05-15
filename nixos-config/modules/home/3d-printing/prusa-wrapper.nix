# modules/home/3d-printing/prusa-wrapper.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Create a simple wrapper script
  prusa-wrapper = pkgs.writeShellScriptBin "prusa-wrapper" ''
    #!/usr/bin/env bash

    # Set a well-supported GTK theme
    export GTK_THEME="Adwaita:dark"
    export GDK_BACKEND="x11"

    # Clear potentially problematic GTK settings
    unset GTK2_RC_FILES
    unset GTK_DATA_PREFIX
    unset GTK_PATH

    # Set clean environment variables
    export XDG_DATA_DIRS="/run/current-system/sw/share:/usr/share:$XDG_DATA_DIRS"
    export NO_AT_BRIDGE=1
    export GTK_CELL_LAYOUT_IGNORE_CONFLICTS=1
    export GTK_IGNORE_ASSERT_FAILURES=1

    # Launch PrusaSlicer with these settings
    exec ${pkgs.prusa-slicer}/bin/prusa-slicer "$@"
  '';
in
{
  # Add the wrapper to your home packages
  home.packages = [ prusa-wrapper ];

  # Add a desktop entry for the wrapper
  xdg.desktopEntries = {
    prusa-wrapper = {
      name = "PrusaSlicer (Fixed)";
      genericName = "3D Printing Slicer";
      comment = "G-code generator for 3D printers (with GTK fixes)";
      exec = "${prusa-wrapper}/bin/prusa-wrapper %F";
      icon = "PrusaSlicer";
      terminal = false;
      categories = [
        "Graphics"
        "3DGraphics"
      ];
    };
  };
}
