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

  # Auto-suspend for power saving
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
      }
      {
        timeout = 600;
        command = "systemctl suspend";
      }
    ];
  };

  # Add power management utilities
  home.packages = with pkgs; [
    powertop
    tlp
    acpi
    upower
    swaylock # For screen locking
    swayidle # For idle management
  ];

  # Add scripts for power management
  home.file.".local/bin/battery-check.sh" = {
    executable = true;
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
}
