# nixos-config/modules/home/laptop/power.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Battery monitoring
  services.cbatticon = {
    enable = true;
    criticalLevelPercent = 10;
    commandCriticalLevel = "systemctl hibernate";
    lowLevelPercent = 20;
    iconType = "standard";
  };

  # Add power management utilities
  home.packages = with pkgs; [
    powertop
    tlp
    acpi
    upower
    swaylock-effects # For screen locking
  ];

  # Add scripts for power management
  home.file.".local/bin/battery-check.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Get battery status
      BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
      CHARGING=$(acpi -b | grep -c "Charging")

      # Check if battery is low and not charging
      if [ "$BATTERY_LEVEL" -le 15 ] && [ "$CHARGING" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Battery Low" "Battery level is $BATTERY_LEVEL%. Please connect charger."
      elif [ "$BATTERY_LEVEL" -le 5 ] && [ "$CHARGING" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Battery Critical" "System will hibernate in 60 seconds."
        sleep 60
        # Check again before hibernating
        BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
        CHARGING=$(acpi -b | grep -c "Charging")
        if [ "$BATTERY_LEVEL" -le 5 ] && [ "$CHARGING" -eq 0 ]; then
          systemctl hibernate
        fi
      fi
    '';
  };

  # Create a battery status script
  home.file.".local/bin/battery-status.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Function to create a notification with battery status
      battery_notification() {
        BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
        CHARGING=$(acpi -b | grep -c "Charging")
        REMAINING=$(acpi -b | grep -oP '(\d+:){1,2}\d+(?= remaining)' || echo "Unknown")

        if [ "$CHARGING" -eq 1 ]; then
          UNTIL_FULL=$(acpi -b | grep -oP '(\d+:){1,2}\d+(?= until charged)' || echo "Unknown")
          ${pkgs.libnotify}/bin/notify-send "Battery Charging" "Level: $BATTERY_LEVEL%\nFull in: $UNTIL_FULL"
        else
          ${pkgs.libnotify}/bin/notify-send "Battery Discharging" "Level: $BATTERY_LEVEL%\nRemaining: $REMAINING"
        fi
      }

      # Run the notification
      battery_notification
    '';
  };

  # Create a cron job to check battery status
  systemd.user.services.battery-check = {
    Unit = {
      Description = "Check battery status";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/battery-check.sh";
    };
  };

  systemd.user.timers.battery-check = {
    Unit = {
      Description = "Run battery check every 5 minutes";
    };
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Add hyprland binding to view battery status
  wayland.windowManager.hyprland.extraConfig = ''
    # Battery status key binding
    bind = $mod, b, exec, ~/.local/bin/battery-status.sh
  '';
}
