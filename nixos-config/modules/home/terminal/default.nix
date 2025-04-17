

# home/stamno/default.nix
{ config, pkgs, lib, inputs, ... }:

let
  # Import color scheme
  colors = import ./theme/colors.nix;
in
{
  imports = [
    # Import home-manager modules for different components
    ./programs.nix
    ./theme.nix

    # Import reusable home-manager modules
    ../../modules/home/desktop/hyprland.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/desktop/dunst.nix
    ../../modules/home/shell
    ../../modules/home/shell/bash.nix
    ../../modules/home/shell/fish.nix
    ../../modules/home/shell/fish-emacs.nix
    ../../modules/home/terminal/alacritty.nix
    ../../modules/home/terminal/kitty.nix
    
    # Import Doom Emacs module
    ../../modules/home/editors/doom-emacs.nix
  ];

  # Home Manager basics
  home.username = "stamno";
  home.homeDirectory = "/home/stamno";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Enable Doom Emacs module
  modules.doom-emacs = {
    enable = true;
    userRepoUrl = "https://github.com/stamnostomp/doom-d";
  };

  # Make the Everblush GTK theme available
  home.packages = with pkgs; [
    # Make the Everblush GTK theme available
    inputs.everblush-gtk.packages.${pkgs.system}.default
  ];

  # Set GTK theme in the environment to ensure it works everywhere
