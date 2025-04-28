# nixos-config/modules/home/laptop/function-keys.nix
{ config, lib, pkgs, ... }:

{
  # Add function key support for ThinkPad to Hyprland
  wayland.windowManager.hyprland.settings = {
    # ThinkPad function key bindings
    bind = [
      # F1 - Help (Open user manual in browser)
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86Display, exec, wdisplays"                             # F7 - Display settings
      ", XF86WLAN, exec, nmcli radio wifi toggle"                  # F8 - Wireless toggle
      ", XF86NotificationCenter, exec, dunstctl history-pop"       # F9 - Notifications
      ", XF86WebCam, exec, grim -g \"$(slurp)\" - | wl-copy"       # F10 - Screenshot (area)
      ", Shift Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png" # F10 + Shift - Save screenshot
      ", XF86Tools, exec, alacritty -e htop"                       # F12 - System monitor
    ];
  };

  # Add notification for volume changes
  home.file.".local/bin/volume-notify.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Get current volume percentage
      VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP '\d+(?=%)')
      MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)

      if [ "$MUTED" -eq 1 ]; then
        ${pkgs.libnotify}/bin/notify-send -t 1000 "Volume" "Muted"
      else
        ${pkgs.libnotify}/bin/notify-send -t 1000 -h int:value:"$VOLUME" "Volume" "Current: $VOLUME%"
      fi
    '';
  };

  # Enhanced volume controls with notification
  wayland.windowManager.hyprland.extraConfig = ''
    # Improved volume controls with notification
    bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ~/.local/bin/volume-notify.sh
    bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.local/bin/volume-notify.sh
    bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.local/bin/volume-notify.sh
  '';

  # Install utilities for function keys
  home.packages = with pkgs; [
    wdisplays    # Display settings
    grim         # Screenshot utility
    slurp        # Area selection
    wl-clipboard # Clipboard manager
  ];
}
