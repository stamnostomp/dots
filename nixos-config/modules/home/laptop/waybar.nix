# nixos-config/modules/home/laptop/waybar.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import colors from the theme module
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;
in
{
  # Waybar configuration
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Waybar configuration files
  xdg.configFile = {
    # Waybar config file
    "waybar/config".text = ''
      {
          "layer": "top",
          "position": "top",
          "height": 24,
          "spacing": 0,
          "margin-top": 0,
          "margin-bottom": 0,

          "modules-left": ["custom/space", "custom/left", "hyprland/workspaces", "custom/right"],
          "modules-center": ["custom/left", "hyprland/window", "custom/right"],
          "modules-right": [
              "custom/left", "cpu", "custom/right", "custom/space",
              "custom/left", "memory", "custom/right", "custom/space",
              "custom/left", "disk", "custom/right", "custom/space",
              "custom/left", "pulseaudio", "custom/right", "custom/space",
              "custom/left", "custom/battery", "custom/right", "custom/space",
              "custom/left", "network", "custom/right", "custom/space",
              "custom/left", "hyprland/language", "custom/right", "custom/space",
              "custom/left", "clock", "custom/right", "custom/space",
              "tray"
          ],

          "hyprland/workspaces": {
              "format": "{icon}",
              "on-click": "activate",
              "all-outputs": false,
              "format-icons": {
                  "1": "1",
                  "2": "2",
                  "3": "3",
                  "4": "4",
                  "5": "5",
                  "6": "6",
                  "7": "7",
                  "8": "8",
                  "9": "9",
                  "10": "10",
                  "default": "○"
              },
              "persistent-workspaces": {
                  "1": [],
                  "2": [],
                  "3": [],
                  "4": []
              }
          },

          "hyprland/window": {
              "format": "{}",
              "max-length": 50,
              "separate-outputs": true
          },

          "cpu": {
              "interval": 2,
              "format": "󰘚 {usage}%",
              "max-length": 10,
              "on-click": "alacritty -e htop"
          },

          "memory": {
              "interval": 5,
              "format": "󰍛 {percentage}%",
              "max-length": 10,
              "on-click": "alacritty -e htop"
          },

          "disk": {
              "interval": 30,
              "format": "󰋊 {percentage_used}%",
              "path": "/"
          },

          "pulseaudio": {
              "format": "{icon} {volume}%",
              "format-muted": "󰝟 Muted",
              "format-icons": {
                  "default": ["󰕿", "󰖀", "󰕾"],
                  "headphone": "󰋋"
              },
              "on-click": "alacritty -e pulsemixer"
          },

          "custom/battery": {
              "exec": "~/.local/bin/dual-battery-status.sh status",
              "return-type": "json",
              "interval": 10,
              "on-click": "~/.local/bin/dual-battery-status.sh click"
          },

          "network": {
              "format-wifi": "  {essid}",
              "format-ethernet": "󰈀 {ipaddr}",
              "format-linked": "󰈀 {ifname} (No IP)",
              "format-disconnected": "󰖪 Disconnected",
              "format-alt": "󱘖 {bandwidthUpBytes} 󱘎 {bandwidthDownBytes}",
              "tooltip-format": "{ifname}: {ipaddr}/{cidr}",
              "on-click": "nm-connection-editor"
          },

          "hyprland/language": {
              "format": "󰌌 {}",
              "keyboard-name": "at-translated-set-2-keyboard",
              "format-en": "QWERTY",
              "format-us": "QWERTY",
              "format-en-dvorak": "DVORAK"
          },

          "clock": {
              "interval": 1,
              "format": "󰥔 {:%H:%M:%S}",
              "format-alt": "󰃭 {:%Y-%m-%d}",
              "tooltip-format": "<tt><small>{calendar}</small></tt>",
              "calendar": {
                  "mode"          : "month",
                  "mode-mon-col"  : 3,
                  "weeks-pos"     : "right",
                  "on-scroll"     : 1,
                  "on-click-right": "mode",
                  "format": {
                      "months":     "<span color='#ffead3'><b>{}</b></span>",
                      "days":       "<span color='#ecc6d9'><b>{}</b></span>",
                      "weeks":      "<span color='#99ffdd'><b>W{}</b></span>",
                      "weekdays":   "<span color='#ffcc66'><b>{}</b></span>",
                      "today":      "<span color='#ff6699'><b><u>{}</u></b></span>"
                  }
              }
          },

          "tray": {
              "icon-size": 18,
              "spacing": 10
          },

          "custom/left": {
              "format": ""
          },

          "custom/right": {
              "format": ""
          },

          "custom/space": {
              "format": " "
          }
      }
    '';

    # Waybar CSS with battery styling
    "waybar/style.css".text = ''
      * {
          font-family: ${colorsDef.font};
          font-size: 13px;
          border: none;
          border-radius: 0;
      }

      window#waybar {
          background-color: ${colors.waybarbg};
          color: #dadada;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #dadada;
      }

      #workspaces button.active {
          background-color: #32302f;
          color: #dadada;
          border-bottom: 2px solid #427b58;
      }

      #workspaces button:hover {
          background: rgba(50, 48, 47, 0.5);
      }

      #window {
          padding: 0 10px;
      }

      #cpu {
          color: ${colors.blue};
      }

      #memory {
          color: ${colors.magenta};
      }

      #disk {
          color: ${colors.cyan};
      }

      #pulseaudio {
          color: ${colors.yellow};
      }

      #custom-battery {
          color: ${colors.green};
      }

      #custom-battery.Charging {
          color: ${colors.brightGreen};
      }

      #custom-battery.Full {
          color: ${colors.brightGreen};
      }

      #custom-battery.warning {
          color: ${colors.yellow};
      }

      #custom-battery.critical {
          color: ${colors.red};
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #network {
          color: ${colors.brightBlue};
      }

      #network.disconnected {
          color: ${colors.red};
      }

      #network.disabled {
          color: ${colors.brightBlack};
      }

      @keyframes blink {
          to {
              color: ${colors.background};
              background-color: ${colors.red};
          }
      }

      #clock {
          color: ${colors.brightCyan};
      }

      #language {
          color: ${colors.brightYellow};
      }

      #custom-left {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      #custom-right {
          font-size: 20px;
          color: ${colors.waybarbg};
          background-color: transparent;
          margin: 0;
          padding: 0;
      }

      #cpu, #memory, #disk, #pulseaudio, #custom-battery, #network, #language, #clock {
          padding: 0 10px;
          background-color: ${colors.waybarbg};
      }

      #workspaces {
          background-color: ${colors.waybarbg};
          padding: 0 5px;
      }

      #window {
          background-color: ${colors.waybarbg};
      }

      #tray {
          padding: 0 10px;
          margin-right: 5px;
      }

      tooltip {
          background-color: ${colors.background};
          border: 1px solid ${colors.blue};
          border-radius: 2px;
      }

      tooltip label {
          color: ${colors.foreground};
      }
    '';
  };

  # Add required packages for Waybar
  home.packages = with pkgs; [
    waybar
    libnotify
    networkmanagerapplet
  ];

  # Install dual battery status script
  home.file.".local/bin/dual-battery-status.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Custom battery script for dual battery ThinkPad T470
      # Shows average charge and handles detailed status

      get_battery_info() {
          local bat=$1
          local bat_path="/sys/class/power_supply/$bat"

          if [[ ! -d "$bat_path" ]]; then
              echo "0 Unknown Unknown"
              return
          fi

          local capacity=$(cat "$bat_path/capacity" 2>/dev/null || echo "0")
          local status=$(cat "$bat_path/status" 2>/dev/null || echo "Unknown")
          local condition=$(cat "$bat_path/cycle_count" 2>/dev/null || echo "Unknown")

          echo "$capacity $status $condition"
      }

      get_combined_status() {
          # Get info for both batteries
          local bat0_info=($(get_battery_info "BAT0"))
          local bat1_info=($(get_battery_info "BAT1"))

          local bat0_capacity=''${bat0_info[0]}
          local bat0_status=''${bat0_info[1]}

          local bat1_capacity=''${bat1_info[0]}
          local bat1_status=''${bat1_info[1]}

          # Calculate average capacity
          local avg_capacity=$(( (bat0_capacity + bat1_capacity) / 2 ))

          # Determine overall status
          local overall_status="Discharging"
          if [[ "$bat0_status" == "Charging" || "$bat1_status" == "Charging" ]]; then
              overall_status="Charging"
          elif [[ "$bat0_status" == "Full" && "$bat1_status" == "Full" ]]; then
              overall_status="Full"
          elif [[ "$bat0_status" == "Not charging" || "$bat1_status" == "Not charging" ]]; then
              overall_status="Not charging"
          fi

          # Determine icon based on average capacity and status
          local icon=""
          if [[ "$overall_status" == "Charging" ]]; then
              icon="󰂄"
          elif [[ "$overall_status" == "Full" ]]; then
              icon="󰁹"
          elif [[ $avg_capacity -ge 90 ]]; then
              icon="󰂂"
          elif [[ $avg_capacity -ge 80 ]]; then
              icon="󰂁"
          elif [[ $avg_capacity -ge 70 ]]; then
              icon="󰂀"
          elif [[ $avg_capacity -ge 60 ]]; then
              icon="󰁿"
          elif [[ $avg_capacity -ge 50 ]]; then
              icon="󰁾"
          elif [[ $avg_capacity -ge 40 ]]; then
              icon="󰁽"
          elif [[ $avg_capacity -ge 30 ]]; then
              icon="󰁼"
          elif [[ $avg_capacity -ge 20 ]]; then
              icon="󰁻"
          elif [[ $avg_capacity -ge 10 ]]; then
              icon="󰁺"
          else
              icon="󰂎"
          fi

          echo "{\"text\":\"$icon $avg_capacity%\",\"tooltip\":\"BAT0: $bat0_capacity% ($bat0_status)\\nBAT1: $bat1_capacity% ($bat1_status)\\nAverage: $avg_capacity%\",\"class\":\"$overall_status\",\"percentage\":$avg_capacity}"
      }

      show_detailed_status() {
          # Get detailed info for both batteries
          local bat0_info=($(get_battery_info "BAT0"))
          local bat1_info=($(get_battery_info "BAT1"))

          local bat0_capacity=''${bat0_info[0]}
          local bat0_status=''${bat0_info[1]}
          local bat0_cycles=''${bat0_info[2]}

          local bat1_capacity=''${bat1_info[0]}
          local bat1_status=''${bat1_info[1]}
          local bat1_cycles=''${bat1_info[2]}

          # Get additional info
          local bat0_voltage=$(cat "/sys/class/power_supply/BAT0/voltage_now" 2>/dev/null | awk '{print $1/1000000 "V"}' || echo "Unknown")
          local bat1_voltage=$(cat "/sys/class/power_supply/BAT1/voltage_now" 2>/dev/null | awk '{print $1/1000000 "V"}' || echo "Unknown")

          local bat0_energy=$(cat "/sys/class/power_supply/BAT0/energy_now" 2>/dev/null | awk '{print $1/1000000 "Wh"}' || echo "Unknown")
          local bat1_energy=$(cat "/sys/class/power_supply/BAT1/energy_now" 2>/dev/null | awk '{print $1/1000000 "Wh"}' || echo "Unknown")

          local avg_capacity=$(( (bat0_capacity + bat1_capacity) / 2 ))

          # Create notification
          local message="🔋 Battery Status Report

      📊 Overall Average: ''${avg_capacity}%

      🔋 BAT0 (Internal):
         • Charge: ''${bat0_capacity}%
         • Status: ''${bat0_status}
         • Voltage: ''${bat0_voltage}
         • Energy: ''${bat0_energy}
         • Cycles: ''${bat0_cycles}

      🔋 BAT1 (External):
         • Charge: ''${bat1_capacity}%
         • Status: ''${bat1_status}
         • Voltage: ''${bat1_voltage}
         • Energy: ''${bat1_energy}
         • Cycles: ''${bat1_cycles}"

          # Send notification
          ${pkgs.libnotify}/bin/notify-send "Battery Status" "$message" -t 8000 -i battery
      }

      # Main logic
      case "''${1:-status}" in
          "status")
              get_combined_status
              ;;
          "detailed"|"click")
              show_detailed_status
              ;;
          *)
              get_combined_status
              ;;
      esac
    '';
  };
}
