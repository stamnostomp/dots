# modules/system/default.nix
{ ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./networking.nix
    ./torrenting.nix
    ./flatpack.nix
    ./trezor.nix
  ];
}
