# modules/home/desktop/default.nix
{ ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./dunst.nix
  ];
}
