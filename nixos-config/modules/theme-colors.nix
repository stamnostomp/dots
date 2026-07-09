# modules/theme-colors.nix
# This is a central module for theme definitions (colors, cursor, font) to
# avoid import problems. Plain data only - packages are attached where a
# `pkgs` argument is available (home/stamno/theme.nix).
{
  # Cursor theme: classic black macOS arrow from pkgs.apple-cursor
  cursor = {
    name = "macOS";
    size = 24;
  };

  # UI font stack (waybar, wofi, ...). Cherry is the primary bitmap font.
  font = "Cherry, Cozette, JetBrainsMono Nerd Font, Siji, FontAwesome";
  fontSize = "13px";

  colors = {
    background = "#141b1e";
    foreground = "#dadada";
    cursor = "#dadada";
    black = "#232a2d";
    red = "#e57474";
    green = "#8ccf7e";
    yellow = "#e5c76b";
    blue = "#67b0e8";
    magenta = "#c47fd5";
    cyan = "#6cbfbf";
    white = "#b3b9b8";
    brightBlack = "#2d3437";
    brightRed = "#ef7e7e";
    brightGreen = "#96d988";
    brightYellow = "#f4d67a";
    brightBlue = "#71baf2";
    brightMagenta = "#ce89df";
    brightCyan = "#67cbe7";
    brightWhite = "#bdc3c2";

    # New light background for waybar
    waybarbg = "#232a2d"; # Using the black color as a lighter background
  };
}
