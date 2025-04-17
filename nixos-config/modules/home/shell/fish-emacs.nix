# modules/home/shell/fish-emacs.nix
{ config, lib, pkgs, ... }:

{
  # Configure Fish shell to work with Emacs
  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Ensure Emacs can work with Fish shell
    if set -q INSIDE_EMACS
        set -gx SHELL ${pkgs.bash}/bin/bash
    end
    
    # Add support for Emacs vterm
    function vterm_printf
      if begin; [ -n "$TMUX" ] && string match -q -r "screen|tmux" "$TERM"; end
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
      else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$argv"
      else
        printf "\e]%s\e\\" "$argv"
      end
    end

    # vterm directory tracking
    function vterm_prompt_end
      vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
    end

    # Emacs vterm clear command
    function clear
      if test -n "$INSIDE_EMACS"
        vterm_printf "51;Evterm-clear-scrollback"
        echo -ne "\033c"
      else
        command clear
      end
    end

    # Set up vterm hooks for Fish shell if inside Emacs
    if test -n "$INSIDE_EMACS"
      functions -c fish_prompt _old_fish_prompt_with_vterm
      function fish_prompt
        _old_fish_prompt_with_vterm
        vterm_prompt_end
      end
    end
  '';

  # Add special support for Emacs shell mode in Bash as well
  programs.bash.initExtra = lib.mkAfter ''
    # Set up proper shell inside Emacs
    if [ -n "$INSIDE_EMACS" ]; then
      export SHELL=${pkgs.bash}/bin/bash
      unset INSIDE_EMACS
      exec fish
    fi
  '';
}
