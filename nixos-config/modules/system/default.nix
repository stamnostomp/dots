# modules/system/default.nix
{ ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./networking.nix
    ./torrenting.nix
    ./flatpack.nix
    ./sunshine.nix
    ./kdeconnect.nix
    ./trezor.nix
    ./printing.nix
    ./pulsar-mouse.nix
  ];
}
