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
      {
        _args = [
          "XF86MonBrightnessUp"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set +5%")'')
        ];
      }
      {
        _args = [
          "XF86MonBrightnessDown"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'')
        ];
      }
      # Improved brightness controls with notification
      # (previously a separate extraConfig block; merged here, same binds)
      {
        _args = [
          "XF86MonBrightnessUp"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set +5% && ~/.local/bin/brightness-notify.sh")'')
        ];
      }
      {
        _args = [
          "XF86MonBrightnessDown"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%- && ~/.local/bin/brightness-notify.sh")'')
        ];
      }
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

  # Install brightnessctl utilities
  # (`light` was removed from nixpkgs; everything here uses brightnessctl)
  home.packages = with pkgs; [
    brightnessctl
  ];
}
