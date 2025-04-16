# hosts/desktop/hardware.nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3c594be5-3f75-4660-ae81-db8085e191dd";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DF79-3471";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6d07fae1-c87b-41a8-9bfc-fc5eabb028c4"; }
    ];

  # Enables DHCP on each ethernet and wireless interface
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp56s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp57s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Additional hardware settings for your Hyprland setup
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
