# nixos-config/modules/home/laptop/hyprland-battery.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;
in
{
  # Battery-optimized Hyprland settings
  wayland.windowManager.hyprland.settings = {
    # Optimize animations for battery life
    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.00";
      animation = [
        "windows, 1, 5, myBezier"
        "windowsOut, 1, 5, default, popin 80%"
        "border, 1, 8, default"
        "fade, 1, 5, default"
        "workspaces, 1, 5, default"
      ];
    };

    # Battery-friendly general settings
    general = {
      gaps_in = 3;         # Smaller gaps to save screen space
      gaps_out = 5;
      border_size = 2;     # Thinner borders
      "col.active_border" = "rgba(6cbfbfee)";
      "col.inactive_border" = "rgba(b3b9b8aa)";
      layout = "dwindle";
    };

    # Better battery life settings
    misc = {
      vfr = true;          # Variable refresh rate
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      disable_autoreload = true;  # Disable config auto-reload to save resources
    };

    # Background processes
    exec-once = [
      "hypridle"           # Idle manager for power saving
    ];

    # Multi-monitor support for ThinkPad
    monitor = [
      # Internal display
      "eDP-1,1920x1080@60,0x0,1"
      # Generic external display configuration
      ",preferred,auto,1"
    ];

    # Better dwindle layout for small screens
    dwindle = {
      pseudotile = true;
      preserve_split = true;
      no_gaps_when_only = true;  # Remove gaps when only one window
    };
  };

  # Create a battery status indicator in the system tray
  home.file.".config/hypr/scripts/battery-status.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Get battery status
      get_bat_status() {
        BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
        CHARGING=$(acpi -b | grep -c "Charging")

        if [ "$CHARGING" -eq 1 ]; then
          echo "🔌 $BATTERY_LEVEL%"
        else
          if [ "$BATTERY_LEVEL" -le 10 ]; then
            echo "🪫 $BATTERY_LEVEL%"
          elif [ "$BATTERY_LEVEL" -le 25 ]; then
            echo "🔋 $BATTERY_LEVEL%"
          elif [ "$BATTERY_LEVEL" -le 50 ]; then
            echo "🔋 $BATTERY_LEVEL%"
          elif [ "$BATTERY_LEVEL" -le 75 ]; then
            echo "🔋 $BATTERY_LEVEL%"
          else
            echo "🔋 $BATTERY_LEVEL%"
          fi
        fi
      }

      # Main loop
      while true; do
        get_bat_status
        sleep 30
      done
    '';
  };

  # Create a minimal wallpaper to save resources
  home.activation.generateMinimalWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/hypr
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 "xc:${colors.background}" ~/.config/hypr/wallpaper-minimal.png
  '';

  # Hyprpaper configuration with minimal resource usage
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.config/hypr/wallpaper-minimal.png
    wallpaper = eDP-1,~/.config/hypr/wallpaper-minimal.png
    ipc = off
    splash = false
  '';

  # Install tools for battery optimization
  home.packages = with pkgs; [
    hypridle
    acpi
  ];
}
