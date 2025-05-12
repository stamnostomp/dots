# modules/system/orca-slicer.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules.orca-slicer;
in
{
  options.modules.orca-slicer = {
    enable = mkEnableOption "Orca Slicer with GTK fixes";
  };

  config = mkIf cfg.enable {
    # Add this inside the config = mkIf cfg.enable { ... } block

    # Create a desktop entry
    environment.etc."xdg/autostart/orca-slicer-fixed.desktop".text = ''
      [Desktop Entry]
      Name=Orca Slicer (Fixed)
      Comment=3D printing slicer with GTK fixes
      Exec=orca-slicer
      Icon=${pkgs.orca-slicer}/share/icons/hicolor/128x128/apps/orca-slicer.png
      Terminal=false
      Type=Application
      Categories=Graphics;3DGraphics;Engineering;
      Keywords=3D;Slicer;Printing;
    '';

    # Create a launcher script in /usr/local/bin
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "launch-orca-slicer" ''
        #!/bin/sh
        export GTK_THEME="Adwaita:light"
        export GDK_BACKEND="x11"
        export LIBGL_DEBUG="verbose"
        ${pkgs.orca-slicer-fixed}/bin/orca-slicer "$@"
      '')
    ];
    # Add the fixed Orca Slicer to system packages
    environment.systemPackages = with pkgs; [
      orca-slicer-fixed
    ];

    # Add any required system configurations
    programs.dconf.enable = true;
    # Ensure GTK3 is available for Orca Slicer
    environment.systemPackages = with pkgs; [
      gtk3
      glib
      pango
      cairo
      gdk-pixbuf
      atk
      libGLU
      mesa
    ];
  };
}
