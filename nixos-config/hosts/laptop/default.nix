# hosts/laptop/default.nix
{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:

{
  imports = [
    # Import system modules
    ../../modules/system
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call # Required for TLP battery threshold setting
#    thinkpad_acpi
  ];

  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = false; # This is fine for desktop, but disable if using TLP
  # Basic system settings

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  # ThinkPad-specific tweaks
  boot.kernelParams = [ "i915.enable_psr=0" ]; # Fix for screen flicker on some T470 models

  boot.kernelModules = [
    "acpi_call"
    "thinkpad_acpi"
  ];
  # User account
  users.users.stamno = {
    isNormalUser = true;
    description = "stamno";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable sound with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Power management for laptop
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      # Battery charge thresholds
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # System packages specific to laptop
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    brightnessctl # Backlight control
  ];

  # This value determines the NixOS release
  system.stateVersion = "25.05";
}
