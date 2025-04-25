# modules/home/shell/default.nix
{ ... }:

{
  imports = [
    ./bash.nix
    ./fish.nix
    ./fish-emacs.nix
    ./fish-tide.nix # Added the Tide configuration
    ./programs.nix
    # Removing the Starship config since we're using Tide now
    # ./theme.nix
  ];
}
