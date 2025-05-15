# modules/home/3d-printing/simple-fix.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Add a wrapper script for Prusa Slicer without desktop entry
  home.file.".local/bin/prusa-fixed" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Set a well-supported GTK theme
      export GTK_THEME="Adwaita:light"
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

      # Launch Prusa Slicer with these settings
      exec ${pkgs.prusa-slicer}/bin/prusa-slicer "$@"
    '';
  };
}
