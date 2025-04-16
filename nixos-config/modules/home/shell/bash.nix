# modules/home/shell/bash.nix
{ config, lib, pkgs, ... }:

{
  # Bash configuration
  programs.bash = {
    enable = true;
    initExtra = ''
      # Better nix-shell integration
      if [ -e /etc/profile ]; then
        source /etc/profile
      fi

      # Add nix-shell indicator to prompt
      __prompt_nix_shell() {
        if [ -n "$IN_NIX_SHELL" ]; then
          echo -n " (nix-shell) "
        fi
      }

      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__prompt_nix_shell)\$ '
    '';
  };
}
