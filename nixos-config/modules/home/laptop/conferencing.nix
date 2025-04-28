# nixos-config/modules/home/laptop/conferencing.nix
{ config, lib, pkgs, ... }:

{
  # Add conferencing tools
  home.packages = with pkgs; [
    pavucontrol        # Audio controls
    pamixer            # CLI audio mixer
    helvum             # Pipewire patchbay
    easyeffects        # Audio processing
    v4l-utils          # Webcam utilities
  ];

  # Add microphone key bindings
  wayland.windowManager.hyprland.settings = {
    bind = [
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ~/.local/bin/mic-notify.sh"
    ];
  };

  # Add microphone mute notification
  home.file.".local/bin/mic-notify.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Check microphone status
      MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c MUTED)

      if [ "$MUTED" -eq 1 ]; then
        ${pkgs.libnotify}/bin/notify-send -t 2000 -u critical "Microphone" "MUTED"
      else
        ${pkgs.libnotify}/bin/notify-send -t 2000 "Microphone" "ACTIVE"
      fi
    '';
  };

  # Create a quick access for video settings
  home.file.".local/bin/webcam-settings.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash
      ${pkgs.v4l-utils}/bin/v4l2-ctl --list-devices
      echo "Press enter to open webcam settings"
      read
      ${pkgs.v4l-utils}/bin/v4l2ucp
    '';
  };
}
