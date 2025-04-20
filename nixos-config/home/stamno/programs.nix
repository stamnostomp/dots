# home/stamno/programs.nix
{ config, lib, pkgs, inputs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "stamno";  # Replace with your actual name
    userEmail = "your.email@example.com";  # Replace with your email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
    };
  };

  # Direnv for per-directory environment variables
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Application packages
  home.packages = with pkgs; [
    # Browsers
    firefox

    # Development tools
    git
    ripgrep
    htop
    btop
    # File managers
    xfce.thunar
    kdePackages.dolphin

    # Messaging and communication
    signal-desktop  # Changed from signal-desktop-source
    vesktop

    # System utilities
    imagemagick
    wl-clipboard
    grim  # Screenshot utility
    slurp  # Area selection for screenshots
    grimblast  # Wrapper for grim and slurp

    # Audio utilities
    pamixer  # CLI audio control
    pavucontrol  # GUI audio control

    # Other utilities
    xdg-utils
    libnotify  # Notification library
  ];

  # Starship prompt (optional)
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      nix_shell = {
        format = lib.mkForce "via [☃️ $state( $name)](bold blue) ";
        heuristic = true;
      };
    };
  };
}
