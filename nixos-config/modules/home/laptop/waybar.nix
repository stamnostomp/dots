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
              "custom/left", "battery", "custom/right", "custom/space",
              "custom/left", "network", "custom/right", "custom/space",
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

          "battery": {
              "bat": "BAT0",
              "adapter": "AC",
              "interval": 10,
              "states": {
                  "warning": 30,
                  "critical": 15
              },
              "format": "{icon} {capacity}%",
              "format-charging": "󰂄 {capacity}%",
              "format-plugged": "󰚥 {capacity}%",
              "format-alt": "{icon} {time}",
              "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
              "on-click": "~/.local/bin/battery-status.sh"
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
          font-family: "Cozette", "JetBrainsMono Nerd Font", "Siji", "FontAwesome";
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

      #battery {
          color: ${colors.green};
      }

      #battery.charging, #battery.plugged {
          color: ${colors.brightGreen};
      }

      #battery.warning {
          color: ${colors.yellow};
      }

      #battery.critical {
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

      #cpu, #memory, #disk, #pulseaudio, #battery, #network, #clock {
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
}
