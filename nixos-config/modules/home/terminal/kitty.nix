# modules/home/terminal/kitty.nix
{ config, lib, pkgs, ... }:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "monospace";
      font_size = "11.0";
      window_padding_width = "10";
      background_opacity = "0.95";

      # Everblush Colors
      foreground = colors.foreground;
      background = colors.background;
      cursor = colors.cursor;

      color0 = colors.black;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.magenta;
      color6 = colors.cyan;
      color7 = colors.white;

      color8 = colors.brightBlack;
      color9 = colors.brightRed;
      color10 = colors.brightGreen;
      color11 = colors.brightYellow;
      color12 = colors.brightBlue;
      color13 = colors.brightMagenta;
      color14 = colors.brightCyan;
      color15 = colors.brightWhite;
    };
  };
}
