# nixos-config/modules/home/laptop/network.nix
{ config, lib, pkgs, ... }:

{
  # Wi-Fi management GUI
  home.packages = with pkgs; [
    networkmanagerapplet  # Network system tray
#    nm-tray              # Lightweight network tray
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

  # Add network manager to autostart (exec-once equivalent: runs once at
  # startup, not on every `hyprctl reload`)
  wayland.windowManager.hyprland.settings = {
    on = [
      {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("nm-applet --indicator")
            end
          '')
        ];
      }
    ]; # Network tray icon

    # ThinkPad Fn+F8 (airplane mode) key binding
    bind = [
      {
        _args = [
          "XF86WLAN"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("~/.local/bin/toggle-wireless.sh")'')
        ];
      }
    ];
  };
}
