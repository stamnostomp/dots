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
              "custom/left", "battery#bat1", "custom/right", "custom/space",
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
                  "4": [],
                  "5": [],
                  "6": [],
                  "7": [],
                  "8": [],
                  "9": [],
                  "10": []
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
              "max-length": 10
          },

          "memory": {
              "interval": 5,
              "format": "󰍛 {percentage}%",
              "max-length": 10
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
              "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
          },

          "battery#bat1": {
              "bat": "BAT1",
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
              "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
          },

          "clock": {
              "interval": 1,
              "format": "󰥔 {:%H:%M:%S}",
              "format-alt": "󰃭 {:%Y-%m-%d}"
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
          color: #83a598;
      }

      #memory {
          color: #d3869b;
      }

      #disk {
          color: #8ec07c;
      }

      #pulseaudio {
          color: #fabd3f;
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

      #battery#bat1 {
          color: ${colors.cyan};
      }

      #battery#bat1.charging, #battery#bat1.plugged {
          color: ${colors.brightCyan};
      }

      #battery#bat1.warning {
          color: ${colors.yellow};
      }

      #battery#bat1.critical {
          color: ${colors.red};
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
