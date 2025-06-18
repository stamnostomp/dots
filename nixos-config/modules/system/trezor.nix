# modules/system/trezor.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable Trezor support
  services.trezord.enable = true;

  # Additional udev rules for Trezor devices
  services.udev.packages = with pkgs; [
    trezor-udev-rules
  ];

  # Add users to the trezor group
  users.groups.trezor = { };

  # System packages (optional - you might prefer to install via home-manager)
  environment.systemPackages = with pkgs; [
    # Trezor utilities
    trezor-suite
    trezorctl
  ];

  # Make sure the user is in the necessary groups
  users.users.stamno.extraGroups = [ "trezor" ];
}
