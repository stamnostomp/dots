# modules/system/pulsar-mouse.nix
{ pkgs, ... }:

{
  # Pulsar mouse configuration tool (GUI + CLI)
  environment.systemPackages = [ pkgs.pulsar-mouse-linux ];

  # Ship the udev rules (lib/udev/rules.d) so the mouse is accessible
  # without sudo — TAG+="uaccess" grants access via systemd-logind ACLs.
  services.udev.packages = [ pkgs.pulsar-mouse-linux ];
}
