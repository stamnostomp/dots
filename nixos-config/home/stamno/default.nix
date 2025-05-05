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
  laptopModule = if isLaptop then ../../modules/home/laptop else null;
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
    ../../modules/home/browser/firefox.nix

    # Conditionally import laptop-specific modules

    # Import Doom Emacs module
    ../../modules/home/editors/doom-emacs.nix
  ] ++ lib.optional isLaptop laptopModule;

  # Home Manager basics
  home.username = "stamno";
  home.homeDirectory = "/home/stamno";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Enable Doom Emacs module
  modules.doom-emacs = {
    enable = true;
    # The repoUrl is deprecated but kept for compatibility
    repoUrl = "https://github.com/stamnostomp/doom-d";
  };

  # Rest of configuration remains the same...
}
