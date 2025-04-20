
# modules/home/shell/theme.nix
{ config, lib, pkgs, ... }:

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
    settings = {
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
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
        vicmd_symbol = "[V](bold green)";
      };
      
      # Directory module
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold blue";
      };
      
      # Git configuration
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold purple";
      };
      
      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold yellow";
      };
      
      # Time module
      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%H:%M";
        style = "bright-black";
      };
      
      # Nix shell indicator
      nix_shell = {
        format = "via [☃️ $state( $name)]($style) ";
        style = "bold blue";
        heuristic = true;
      };
      
      # Remove the palette configuration as it's not supported this way
      # Instead, apply colors directly in module styles
    };
  };
  
  # Terminal colors for Bash
  programs.bash.initExtra = lib.mkAfter ''
    # Set LS_COLORS for Bash
    export LS_COLORS="di=1;34:ln=1;36:so=1;31:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=1;41:sg=1;46:tw=1;42:ow=1;43"
  '';
  
  # Terminal colors for Fish
  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Set Fish colors using Everblush theme
    set -U fish_color_normal ${colors.foreground}
    set -U fish_color_command ${colors.blue}
    set -U fish_color_param ${colors.brightWhite}
    set -U fish_color_quote ${colors.green}
    set -U fish_color_redirection ${colors.cyan}
    set -U fish_color_error ${colors.red}
    set -U fish_color_comment ${colors.brightBlack}
    set -U fish_color_operator ${colors.yellow}
    set -U fish_color_escape ${colors.magenta}
    set -U fish_color_autosuggestion ${colors.brightBlack}
    set -U fish_color_search_match --background=${colors.brightBlack}
    set -U fish_color_selection --background=${colors.brightBlack}
  '';
}
