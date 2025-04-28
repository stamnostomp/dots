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
      lock_cmd = swaylock -f -c 000000
      unlock_cmd = pkill -USR1 swaylock
      before_sleep_cmd = swaylock -f -c 000000
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 300          # 5 min
      on-timeout = swaylock -f -c 000000
    }

    listener {
      timeout = 600          # 10 min
      on-timeout = hyprctl dispatch dpms off
    }

    listener {
      timeout = 900          # 15 min
      on-timeout = systemctl suspend
    }
  '';

  # Add hypridle to the import list
  imports = [
    # Additional imports can go here
  ];

  # Install necessary packages
  home.packages = with pkgs; [
    hypridle
    swaylock
  ];
}
