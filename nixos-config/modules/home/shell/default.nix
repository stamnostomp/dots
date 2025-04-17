# modules/home/shell/default.nix
{ ... }:

{
  imports = [
    ./bash.nix
    ./fish.nix
    ./fish-emacs.nix
    ./programs.nix
    ./theme.nix
  ];
}
