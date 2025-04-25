# modules/home/shell/theme.nix
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
  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = lib.mkForce {
      # Basic configuration
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$character"
      ];

      # Character module (the prompt symbol)
      character = {
        success_symbol = "[➜](bold bright-green)";
        error_symbol = "[✗](bold bright-red)";
        vicmd_symbol = "[V](bold bright-green)";
      };

      # Directory module
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold bright-blue";
      };

      # Git configuration
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold bright-purple";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold bright-yellow";
      };

      # Time module
      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%H:%M";
        style = "bright-white";
      };

      # Nix shell indicator
      nix_shell = {
        format = "via [☃️ $state( $name)]($style) ";
        style = "bold bright-blue";
        heuristic = true;
      };
    };
  };

  # Terminal colors for Bash
  programs.bash.initExtra = lib.mkAfter ''
    # Set LS_COLORS for Bash
    export LS_COLORS="di=1;34:ln=1;36:so=1;31:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=1;41:sg=1;46:tw=1;42:ow=1;43"
  '';

  # Terminal colors for Fish with higher contrast
  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Set Fish colors using Everblush theme with higher contrast
    set -U fish_color_normal ${colors.brightWhite}  # Much brighter for normal text
    set -U fish_color_command ${colors.brightBlue}  # Bright blue for commands
    set -U fish_color_param ${colors.brightWhite}   # Bright white for parameters
    set -U fish_color_quote ${colors.brightGreen}   # Bright green for quotes
    set -U fish_color_redirection ${colors.brightCyan}  # Bright cyan for redirections
    set -U fish_color_error ${colors.brightRed}     # Bright red for errors
    set -U fish_color_comment "#557784"    # Custom brighter color for comments
    set -U fish_color_operator ${colors.brightYellow}  # Bright yellow for operators
    set -U fish_color_escape ${colors.brightMagenta}  # Bright magenta for escape characters
    set -U fish_color_autosuggestion "#6c7086"  # Custom brighter color for autosuggestions
    set -U fish_color_search_match --background=${colors.blue}  # Background highlight for search
    set -U fish_color_selection --background=${colors.blue}  # Background for selection

    # Fish prompt colors (PS1 equivalent)
    set -U fish_color_user ${colors.brightGreen}  # User name in bright green
    set -U fish_color_host ${colors.brightCyan}   # Hostname in bright cyan
    set -U fish_color_cwd ${colors.brightBlue}    # Current directory in bright blue

    # Update prompt with high contrast colors
    function fish_prompt
        set -l last_status $status

        # User and hostname
        set_color $fish_color_user
        printf '%s' $USER
        set_color normal
        printf '@'
        set_color $fish_color_host
        printf '%s' (hostname)
        set_color normal
        printf ':'

        # Current directory
        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal

        # Git status if applicable
        if command -sq git && test -d .git
            printf ' ('
            set_color magenta
            printf (git branch --show-current)
            set_color normal
            printf ')'
        end

        # Nix shell indicator
        if set -q IN_NIX_SHELL
            set_color cyan
            printf ' (nix-shell)'
            set_color normal
        end

        # Prompt character
        if test $last_status -eq 0
            printf '\n%s ' '➜'
        else
            set_color $fish_color_error
            printf '\n%s ' '✗'
            set_color normal
        end
    end
  '';
}
