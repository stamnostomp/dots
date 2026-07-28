# modules/system/printing.nix
{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.brgenml1lpr ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
