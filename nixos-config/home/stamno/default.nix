# home/stamno/default.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
     # Import home-manager modules for different components
    ./programs.nix
    ./theme.nix

    # Import desktop modules
    ../modules/home/desktop
    
    # Import shell and terminal modules
    ../modules/home/shell
    ../modules/home/terminal
    
    # Import Doom Emacs module
    ../modules/home/editors/doom-emacs.nix
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
  home.sessionVariables = {
    GTK_THEME = "Everblush";
  };
}
