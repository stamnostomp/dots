# home/stamno/default.nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Import color scheme directly
  colorsDef = import ./theme/colors.nix;
in
{
  imports = [
    # Import home-manager modules for different components
    ./programs.nix
    ./theme.nix

    # Import reusable home-manager modules
    ../../modules/home/desktop
    ../../modules/home/shell
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

  # Enable Doom Emacs module with GitHub repository
  modules.doom-emacs = {
    enable = true;
    repoUrl = "https://github.com/stamnostomp/doom-d";
  };

  # Make the Everblush GTK theme available
  home.packages = with pkgs; [
    # Make the Everblush GTK theme available
    inputs.everblush-gtk.packages.${pkgs.system}.default

    # Terminal utilities that improve Emacs/shell experience
    ripgrep
    fd
    bat
    #exa

    # Development tools
    git
    gnumake
    gcc

    # Wayland tools
    wl-clipboard

    # Doom Emacs dependencies
    cmake
    python3
  ];

  # Set GTK theme in the environment to ensure it works everywhere
  home.sessionVariables = {
    GTK_THEME = "Everblush";
    # Important for Doom Emacs
    DOOMDIR = "${config.home.homeDirectory}/.doom.d";
    DOOMLOCALDIR = "${config.home.homeDirectory}/.doom-local";
  };

  # Make colors globally available to other modules
  _module.args.colorScheme = colorsDef.colors;
}
