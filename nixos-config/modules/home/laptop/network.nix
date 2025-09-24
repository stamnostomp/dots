# nixos-config/modules/home/laptop/network.nix
{ config, lib, pkgs, ... }:

{
  # Wi-Fi management GUI
  home.packages = with pkgs; [
    networkmanagerapplet  # Network system tray
    nm-tray              # Lightweight network tray
    wpa_supplicant_gui   # WPA configuration tool
  ];

  # Add a script to toggle airplane mode
  home.file.".local/bin/toggle-wireless.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Check current state
      WIFI_ENABLED=$(nmcli radio wifi)
      BLUETOOTH_ENABLED=$(bluetoothctl show | grep "Powered: yes" | wc -l)

      if [ "$WIFI_ENABLED" = "enabled" ] || [ "$BLUETOOTH_ENABLED" -eq 1 ]; then
        # Turn off wireless
        nmcli radio wifi off
        bluetoothctl power off
        notify-send "Airplane Mode" "Wireless radios disabled"
      else
        # Turn on wireless
        nmcli radio wifi on
        bluetoothctl power on
        notify-send "Airplane Mode" "Wireless radios enabled"
      fi
    '';
  };

  # Add network manager to autostart
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "nm-applet --indicator"  # Network tray icon
    ];

    # ThinkPad Fn+F8 (airplane mode) key binding
    bind = [
      ", XF86WLAN, exec, ~/.local/bin/toggle-wireless.sh"
    ];
  };
}
