# modules/home/shell/programs.nix
{ config, lib, pkgs, ... }:

{
  # Shell utilities and programs
  home.packages = with pkgs; [
    # Shell utilities
    bat        # Better cat
#    exa        # Modern ls replacement
    fd         # Alternative to find
    fzf        # Fuzzy finder
    ripgrep    # Fast grep
    jq         # JSON processor
    yq         # YAML processor
    ncdu       # Disk usage analyzer
    htop       # Process viewer
    btop       # Resource monitor
    tmux       # Terminal multiplexer
    
    # Development utilities
    git-extras  # Additional git commands
    git-lfs     # Git large file storage
    gh          # GitHub CLI
    
    # System tools
    tree        # Directory listing as tree
    neofetch    # System info
    lsof        # List open files
    pv          # Pipe viewer
    
    # For Emacs/Doom compatibility
    editorconfig-core-c  # EditorConfig
  ];
  
  # Set up direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
