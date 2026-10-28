# nixos-config/modules/home/laptop/function-keys.nix
{ config, lib, pkgs, ... }:

{
  # Add function key support for ThinkPad to Hyprland
  wayland.windowManager.hyprland.settings = {
    # ThinkPad function key bindings
    bind = [
      # F1 - Help (Open user manual in browser)
      {
        _args = [
          "XF86AudioMute"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
        ];
      }
      {
        _args = [
          "XF86AudioMicMute"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
        ];
      }
      {
        _args = [
          "XF86AudioRaiseVolume"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'')
        ];
      }
      {
        _args = [
          "XF86AudioLowerVolume"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
        ];
      }
      { _args = [ "XF86Display" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wdisplays")'') ]; } # F7 - Display settings
      { _args = [ "XF86WLAN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("nmcli radio wifi toggle")'') ]; } # F8 - Wireless toggle
      { _args = [ "XF86NotificationCenter" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("dunstctl history-pop")'') ]; } # F9 - Notifications
      { _args = [ "XF86WebCam" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]])'') ]; } # F10 - Screenshot (area)
      # F10 + Shift - Save screenshot (was missing the comma between mods and key in hyprlang, fixed here)
      { _args = [ "SHIFT + Print" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png]])'') ]; }
      { _args = [ "XF86Tools" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("alacritty -e htop")'') ]; } # F12 - System monitor

      # Improved volume controls with notification
      # (previously a separate extraConfig block; merged here, same binds)
      {
        _args = [
          "XF86AudioRaiseVolume"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ~/.local/bin/volume-notify.sh")'')
        ];
      }
      {
        _args = [
          "XF86AudioLowerVolume"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.local/bin/volume-notify.sh")'')
        ];
      }
      {
        _args = [
          "XF86AudioMute"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.local/bin/volume-notify.sh")'')
        ];
      }
    ];
  };

  # Add notification for volume changes
  home.file.".local/bin/volume-notify.sh" = {
    executable = true;
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

  # Install utilities for function keys
  home.packages = with pkgs; [
    wdisplays    # Display settings
    grim         # Screenshot utility
    slurp        # Area selection
    wl-clipboard # Clipboard manager
  ];
}
