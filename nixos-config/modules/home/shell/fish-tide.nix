# modules/home/shell/fish-tide.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import colors from the theme module
  inherit (import ../../../home/stamno/theme/colors.nix) colors;
in
{
  # Install tide using nixpkgs fishPlugins but don't use its prompt functions
  programs.fish = {
    plugins = lib.mkBefore [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    # Configure fish prompt and splash text
    interactiveShellInit = lib.mkAfter ''
      # Splash text to display when opening a new terminal
      function fish_greeting
        echo "When I die, I don't know if I'll go to heaven, not sure if they let cowboys in"
      end

      # First, ensure the command duration threshold is set before any functions run
      set -g tide_cmd_duration_threshold 3000

      # Fix for missing CMD_DURATION variable
      if not set -q CMD_DURATION
        set -g CMD_DURATION 0
      end

      # Apply Everblush theme colors
      set -g tide_pwd_color_anchors "${colors.brightBlue}"
      set -g tide_pwd_color_dirs "${colors.brightCyan}"
      set -g tide_pwd_color_truncated_dirs "${colors.blue}"

      set -g tide_cmd_duration_color "${colors.yellow}"
      set -g tide_context_color_default "${colors.green}"
      set -g tide_context_color_root "${colors.red}"
      set -g tide_git_color_branch "${colors.magenta}"
      set -g tide_git_color_conflicted "${colors.red}"
      set -g tide_git_color_dirty "${colors.yellow}"
      set -g tide_git_color_operation "${colors.brightMagenta}"
      set -g tide_git_color_staged "${colors.green}"
      set -g tide_git_color_stash "${colors.blue}"
      set -g tide_git_color_untracked "${colors.brightRed}"
      set -g tide_git_color_upstream "${colors.cyan}"
      set -g tide_status_color_failure "${colors.brightRed}"
      set -g tide_status_color_success "${colors.brightGreen}"
      set -g tide_time_color "${colors.brightWhite}"
      set -g tide_nix_shell_color "${colors.brightBlue}"
      set -g tide_nix_shell_icon "❄️"
      set -g tide_nix_shell_enabled true

      # Helper function to detect nix-shell status
      function __nix_shell_indicator
        if set -q IN_NIX_SHELL
          set_color "${colors.brightBlue}"
          if test "$IN_NIX_SHELL" = "pure"
            echo -n " (❄️ pure)"
          else
            echo -n " (❄️ nix-shell)"
          end
          set_color normal
        end
      end

      # Custom prompt function with better nix-shell support
      function fish_prompt
        set -l last_status $status

        # User and hostname
        set_color "${colors.brightCyan}"
        echo -n (prompt_pwd)
        set_color normal

        # Git info if available
        if command -sq git && git rev-parse --is-inside-work-tree &>/dev/null
          set_color "${colors.magenta}"
          echo -n " ("(git branch --show-current)")"
          set_color normal
        end

        # Nix shell indicator - improved detection
        __nix_shell_indicator

        # Emacs indicator if inside Emacs
        if set -q INSIDE_EMACS
          set_color "${colors.brightGreen}"
          echo -n " (emacs)"
          set_color normal
        end

        # Prompt character
        echo ""
        if test $last_status -eq 0
          set_color "${colors.brightGreen}"
          echo -n "❯ "
        else
          set_color "${colors.brightRed}"
          echo -n "✘ "
        end
        set_color normal
      end

      # Right-side prompt with time and additional info
      function fish_right_prompt
        # Show nix-shell name if available
        if set -q IN_NIX_SHELL
          if set -q NIX_SHELL_NAME
            set_color "${colors.brightBlue}"
            echo -n "[$NIX_SHELL_NAME] "
            set_color normal
          end
        end

        # Time
        set_color "${colors.brightWhite}"
        echo -n (date "+%H:%M:%S")
        set_color normal
      end

      # Function to refresh prompt when entering/exiting nix-shell
      function __refresh_prompt_on_nix_shell --on-variable IN_NIX_SHELL
        # Force prompt refresh
        commandline -f repaint
      end
    '';
  };
}
