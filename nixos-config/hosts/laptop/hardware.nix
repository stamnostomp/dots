# hosts/laptop/hardware.nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # This is a placeholder - will be replaced during installation
  # with your actual hardware configuration

  # Basic boot setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ThinkPad hardware settings
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;

  # Better trackpoint/touchpad support
  hardware.trackpoint = {
    enable = true;
    sensitivity = 100;
    emulateWheel = true;
  };

  # Basic hardware assumptions - adjust during real installation
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pcirowse"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
