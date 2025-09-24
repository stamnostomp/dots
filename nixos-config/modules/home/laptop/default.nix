# modules/home/laptop/default.nix
{ ... }:

{
  imports = [
    ./waybar.nix
    ./power.nix
    ./input.nix
    ./brightness.nix
    ./function-keys.nix
#    ./hyprland-battery.nix
    ./hypridel.nix
    ./network.nix
    ./dock.nix
    ./conferencing.nix
    ./hyprland-standalone.nix  # Use standalone Hyprland config instead of desktop one
  ];
}
