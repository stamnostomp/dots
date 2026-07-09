# home/stamno/default.nix (updated with conditional imports)
{
  config,
  pkgs,
  lib,
  inputs,
  hostname ? "desktop",
  ...
}:

let
  # Import color scheme directly
  colorsDef = import ./theme/colors.nix;
  isLaptop = hostname == "laptop";
in
{
  imports = [
    # Import home-manager modules for different components
    ./programs.nix
    ./theme.nix

    # Import shell modules (common to both)
    ../../modules/home/shell
    
    # Import terminal modules (common to both)
    ../../modules/home/terminal/alacritty.nix
    ../../modules/home/terminal/kitty.nix
    
    # Import browser modules (common to both)
    ../../modules/home/browser/firefox.nix

    # Import Doom Emacs module (common to both)
    ../../modules/home/editors/doom-emacs.nix

    # CAD tooling (KiCad + declarative global library tables)
    ../../modules/home/cad/kicad.nix

    # Conditional imports based on hostname
  ] ++ (if isLaptop then [
    # Laptop-specific modules
    ../../modules/home/laptop
    # Import only the desktop modules that don't conflict
    ../../modules/home/desktop/dunst.nix
    ../../modules/home/desktop/audio.nix
    # Note: NOT importing ../../modules/home/desktop/hyprland.nix to avoid conflicts
    # The laptop modules will handle Hyprland configuration
  ] else [
    # Desktop-specific modules
    ../../modules/home/desktop
  ]);

  # Home Manager basics
  home.username = "stamno";
  home.homeDirectory = "/home/stamno";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Enable Doom Emacs module
  modules.doom-emacs = {
    enable = true;
    # Path to local doom config (symlinked to ~/.doom.d)
    configPath = "${config.home.homeDirectory}/Gits/doom-d";
  };
}
