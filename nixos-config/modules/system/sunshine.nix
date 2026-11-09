# modules/system/sunshine.nix
{ ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS capture
    openFirewall = true;
  };
}
