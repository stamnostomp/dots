# nixos-config/modules/home/laptop/hypridle.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Configure hypridle for power management
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = ${pkgs.swaylock}/bin/swaylock -f -c 000000
      unlock_cmd = pkill -USR1 swaylock
      before_sleep_cmd = ${pkgs.swaylock}/bin/swaylock -f -c 000000
      after_sleep_cmd = ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
    }

    listener {
      timeout = 300          # 5 min
      on-timeout = ${pkgs.swaylock}/bin/swaylock -f -c 000000
    }

    listener {
      timeout = 600          # 10 min
      on-timeout = ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
    }

    listener {
      timeout = 900          # 15 min
      on-timeout = systemctl suspend
    }
  '';

  # Install necessary packages
  home.packages = with pkgs; [
    hypridle
    swaylock-effects
  ];
}
