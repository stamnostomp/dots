# modules/home/terminal/alacritty.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "none";
        opacity = 0.95;
      };
      font = {
        normal = {
          family = "monospace";
          style = "Regular";
        };
        size = 11.0;
      };
      colors = {
        primary = {
          background = colors.background;
          foreground = colors.foreground;
        };
        cursor = {
          text = colors.background;
          cursor = colors.cursor;
        };
        normal = {
          black = colors.black;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.magenta;
          cyan = colors.cyan;
          white = colors.white;
        };
        bright = {
          black = colors.brightBlack;
          red = colors.brightRed;
          green = colors.brightGreen;
          yellow = colors.brightYellow;
          blue = colors.brightBlue;
          magenta = colors.brightMagenta;
          cyan = colors.brightCyan;
          white = colors.brightWhite;
        };
      };
    };
  };
}
