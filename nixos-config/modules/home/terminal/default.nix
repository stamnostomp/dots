# modules/home/terminal/default.nix
{ ... }:

{
  imports = [
    ./alacritty.nix
    ./kitty.nix
  ];
}
