# modules/home/desktop/dunst.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  # FIXED: Direct import that avoids relative path issues
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;
in
{
  # Dunst notification daemon
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "10x50";
        origin = "top-right";
        transparency = 10;
        frame_color = colors.blue;
        separator_color = "frame";
        font = "monospace 11";
      };

      urgency_low = {
        background = colors.background;
        foreground = colors.foreground;
        timeout = 5;
      };

      urgency_normal = {
        background = colors.background;
        foreground = colors.foreground;
        timeout = 10;
      };

      urgency_critical = {
        background = colors.background;
        foreground = colors.red;
        frame_color = colors.red;
        timeout = 0;
      };
    };
  };

  # Add required packages for Dunst
  home.packages = with pkgs; [
    libnotify
  ];
}
