# nixos-config/modules/home/laptop/dock.nix
{ config, lib, pkgs, ... }:

{
  # Create a dock detection and handling script
  home.file.".local/bin/dock-handler.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Monitor connected displays
      connected_displays() {
        hyprctl monitors | grep -c "Monitor"
      }

      # Apply docked configuration
      apply_docked_config() {
        # Configure displays (example for ThinkPad dock - adjust as needed)
        hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x1080, 1"
        hyprctl keyword monitor "DP-1, 3440x1440@60, 0x0, 1"

        # Apply any other dock-specific settings
        hyprctl keyword general:gaps_out 10

        notify-send "Dock Detected" "Applied docked workstation configuration"
      }

      # Apply undocked/mobile configuration
      apply_mobile_config() {
        # Configure for laptop screen only
        hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1"

        # Apply battery-saving settings
        hyprctl keyword general:gaps_out 5

        notify-send "Undocked" "Applied mobile configuration"
      }

      # Main dock detection logic
      display_count=$(connected_displays)

      if [ "$display_count" -gt 1 ]; then
        apply_docked_config
      else
        apply_mobile_config
      fi
    '';
  };

  # Add detect-dock trigger to Hyprland startup
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "~/.local/bin/dock-handler.sh"  # Run at startup
    ];

    # Add manual key binding to re-detect dock status
    bind = [
      "$mod, p, exec, ~/.local/bin/dock-handler.sh"  # Super+P to configure displays
    ];
  };

  # Add udev rule to detect dock events
  home.file.".config/udev/rules.d/99-thinkpad-dock.rules" = {
    text = ''
      # ThinkPad dock detection
      ACTION=="change", SUBSYSTEM=="drm", RUN+="/home/stamno/.local/bin/dock-handler.sh"
    '';
  };

  # Add tools for external displays
  home.packages = with pkgs; [
    wlr-randr
    wdisplays
  ];
}
