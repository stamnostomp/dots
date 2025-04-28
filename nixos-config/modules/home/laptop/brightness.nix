# nixos-config/modules/home/laptop/brightness.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Add key bindings to Hyprland config for brightness control
  wayland.windowManager.hyprland.settings = {
    # Brightness control bindings
    bind = [
      ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ];
  };

  # Add notification for brightness changes
  home.file.".local/bin/brightness-notify.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Get current brightness percentage
      BRIGHTNESS=$(brightnessctl info | grep -oP '\(\K[^%]*')

      # Show notification with brightness level
      ${pkgs.libnotify}/bin/notify-send -t 1000 -h int:value:"$BRIGHTNESS" "Brightness" "Current: $BRIGHTNESS%"
    '';
  };

  # Enhanced brightness control with notification
  wayland.windowManager.hyprland.extraConfig = ''
    # Improved brightness controls with notification
    bind = , XF86MonBrightnessUp, exec, brightnessctl set +5% && ~/.local/bin/brightness-notify.sh
    bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%- && ~/.local/bin/brightness-notify.sh
  '';

  # Install brightness control utilities
  home.packages = with pkgs; [
    brightnessctl
    light
  ];
}
