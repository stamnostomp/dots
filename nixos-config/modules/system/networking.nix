# modules/system/networking.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 22 ];
  };

  # Network packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];
}
