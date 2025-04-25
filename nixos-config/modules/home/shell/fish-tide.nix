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
  # Install tide using nixpkgs fishPlugins
  programs.fish = {
    plugins = lib.mkBefore [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    # Configure tide prompt
    interactiveShellInit = lib.mkAfter ''
      # Initialize Tide prompt if not already configured
      if not set -q _tide_init_done
        # Set tide version to avoid prompt
        set -g _tide_init_done true

        # Set tide color variables to Everblush theme with high contrast
        set -g tide_pwd_color_anchors ${colors.brightBlue}
        set -g tide_pwd_color_dirs ${colors.brightCyan}
        set -g tide_pwd_color_truncated_dirs ${colors.blue}

        set -g tide_cmd_duration_color ${colors.yellow}
        set -g tide_context_color_default ${colors.green}
        set -g tide_context_color_root ${colors.red}
        set -g tide_git_color_branch ${colors.magenta}
        set -g tide_git_color_conflicted ${colors.red}
        set -g tide_git_color_dirty ${colors.yellow}
        set -g tide_git_color_operation ${colors.brightMagenta}
        set -g tide_git_color_staged ${colors.green}
        set -g tide_git_color_stash ${colors.blue}
        set -g tide_git_color_untracked ${colors.brightRed}
        set -g tide_git_color_upstream ${colors.cyan}
        set -g tide_status_color_failure ${colors.brightRed}
        set -g tide_status_color_success ${colors.brightGreen}
        set -g tide_time_color ${colors.brightWhite}
        set -g tide_nix_shell_color ${colors.brightBlue}

        # Configure Tide prompt style - Two-line prompt with arrow
        set -g tide_prompt_icon_connection "╭─"
        set -g tide_left_prompt_frame_enabled true
        set -g tide_right_prompt_frame_enabled true
        set -g tide_prompt_connection_color ${colors.brightBlack}
        set -g tide_left_prompt_suffix ""
        set -g tide_right_prompt_suffix ""
        set -g tide_prompt_add_newline_before true
        set -g tide_left_prompt_frame_color ${colors.brightBlack}
        set -g tide_right_prompt_frame_color ${colors.brightBlack}

        # Configure the prompt character
        set -g tide_prompt_char_icon "❯"
        set -g tide_prompt_char_color_success ${colors.brightGreen}
        set -g tide_prompt_char_color_failure ${colors.brightRed}
        set -g tide_prompt_char_vi_insert_icon "❯"
        set -g tide_prompt_char_vi_normal_icon "N"
        set -g tide_prompt_char_vi_replace_icon "R"
        set -g tide_prompt_char_vi_visual_icon "V"

        # Item configuration
        set -g tide_left_prompt_items 'pwd' 'git' 'newline' 'character'
        set -g tide_right_prompt_items 'status' 'cmd_duration' 'context' 'jobs' 'nix_shell' 'virtual_env' 'time'

        # Enable transient prompt (command moves up after execution)
        set -g tide_transient_prompt 'always'

        # Time settings
        set -g tide_time_format '%H:%M:%S'

        # Git settings
        set -g tide_git_icon ""
        set -g tide_git_truncation_strategy 15

        # Directory settings
        set -g tide_pwd_icon_home ""
        set -g tide_pwd_icon_unwritable "⛔"
        set -g tide_pwd_markers .git .svn .hg
        set -g tide_pwd_truncation_strategy anchors
        set -g tide_pwd_max_dirs 2

        # Status settings
        set -g tide_status_icon "✔"
        set -g tide_status_icon_failure "✘"

        # Nix shell
        set -g tide_nix_shell_icon "❄️ "
        set -g tide_nix_shell_verbose_icon true

        # Command duration
        set -g tide_cmd_duration_threshold 3000
        set -g tide_cmd_duration_decimals 1
        set -g tide_cmd_duration_icon "⏱ "

        # Visual separator between left/right sides
        set -g tide_prompt_icon_separator ""
      end
    '';
  };
}
