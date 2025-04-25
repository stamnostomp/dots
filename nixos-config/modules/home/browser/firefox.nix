# modules/home/browser/firefox.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Import colors from the theme module
  colorsDef = import ../../../modules/theme-colors.nix;
  colors = colorsDef.colors;
in
{
  # Firefox configuration
  programs.firefox = {
    enable = false;
    package = pkgs.firefox-bin;

    # Firefox profiles
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # User preferences
      settings = {
        # Enable userChrome.css and userContent.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Dark mode
        "browser.theme.toolbar-theme" = 0;
        "browser.theme.content-theme" = 0;
        "browser.in-content.dark-mode" = true;
        "ui.systemUsesDarkTheme" = 1;

        # UI customizations
        "browser.tabs.inTitlebar" = 0;
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # Compact UI

        # Privacy settings
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;

        # Disable Pocket
        "extensions.pocket.enabled" = false;

        # Disable telemetry
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
      };

      # User styles
      userChrome = ''
        /* Everblush Firefox Theme - userChrome.css */
        /* This customizes the Firefox UI elements */

        :root {
          --everblush-bg: ${colors.background};
          --everblush-fg: ${colors.foreground};
          --everblush-black: ${colors.black};
          --everblush-bright-black: ${colors.brightBlack};
          --everblush-red: ${colors.red};
          --everblush-green: ${colors.green};
          --everblush-yellow: ${colors.yellow};
          --everblush-blue: ${colors.blue};
          --everblush-magenta: ${colors.magenta};
          --everblush-cyan: ${colors.cyan};
          --everblush-white: ${colors.white};
          --everblush-bright-white: ${colors.brightWhite};

          /* Firefox UI variables */
          --toolbar-bgcolor: var(--everblush-black) !important;
          --toolbar-bgimage: none !important;
          --toolbar-color: var(--everblush-fg) !important;
          --toolbar-non-lwt-bgcolor: var(--everblush-black) !important;
          --toolbar-non-lwt-textcolor: var(--everblush-fg) !important;

          --tab-selected-bgcolor: var(--everblush-bright-black) !important;
          --tab-selected-textcolor: var(--everblush-fg) !important;
          --lwt-tab-text: var(--everblush-fg) !important;
          --lwt-tab-background: var(--everblush-black) !important;

          --lwt-toolbar-field-background-color: var(--everblush-bright-black) !important;
          --lwt-toolbar-field-color: var(--everblush-fg) !important;
          --lwt-toolbar-field-border-color: var(--everblush-blue) !important;
          --lwt-toolbar-field-focus-background-color: var(--everblush-bg) !important;

          --urlbar-popup-url-color: var(--everblush-blue) !important;
          --autocomplete-popup-background: var(--everblush-black) !important;
          --autocomplete-popup-color: var(--everblush-fg) !important;

          --lwt-accent-color: var(--everblush-blue) !important;
          --lwt-sidebar-background-color: var(--everblush-bg) !important;
          --lwt-sidebar-text-color: var(--everblush-fg) !important;
        }

        /* Main window background */
        #main-window {
          background-color: var(--everblush-bg) !important;
          color: var(--everblush-fg) !important;
        }

        /* Tabs styling */
        .tab-background[selected="true"] {
          background-color: var(--everblush-bright-black) !important;
          border-top: 2px solid var(--everblush-blue) !important;
        }

        .tab-content {
          color: var(--everblush-fg) !important;
        }

        .tabbrowser-tab:hover > .tab-stack > .tab-background:not([selected="true"]) {
          background-color: var(--everblush-bright-black) !important;
          opacity: 0.5 !important;
        }

        /* URL bar styling */
        #urlbar-background {
          background-color: var(--everblush-bright-black) !important;
          border: 1px solid var(--everblush-blue) !important;
        }

        #urlbar-input-container {
          color: var(--everblush-fg) !important;
        }

        /* Sidebar styling */
        #sidebar-box {
          background-color: var(--everblush-black) !important;
          color: var(--everblush-fg) !important;
        }

        #sidebar-header {
          background-color: var(--everblush-black) !important;
          color: var(--everblush-fg) !important;
          border-bottom: 1px solid var(--everblush-blue) !important;
        }

        /* Bookmarks toolbar */
        #PersonalToolbar {
          background-color: var(--everblush-black) !important;
          color: var(--everblush-fg) !important;
        }

        /* Buttons */
        .toolbarbutton-1 {
          color: var(--everblush-fg) !important;
        }

        .toolbarbutton-1:hover {
          background-color: var(--everblush-bright-black) !important;
        }

        /* Context menus */
        menupopup {
          --panel-background: var(--everblush-black) !important;
          --panel-color: var(--everblush-fg) !important;
          --panel-border-color: var(--everblush-blue) !important;
          --arrowpanel-background: var(--everblush-black) !important;
          --arrowpanel-color: var(--everblush-fg) !important;
          --arrowpanel-border-color: var(--everblush-blue) !important;
        }

        menuitem, menu {
          color: var(--everblush-fg) !important;
        }

        menuitem:hover, menu:hover {
          background-color: var(--everblush-blue) !important;
          color: var(--everblush-bg) !important;
        }
      '';

      userContent = ''
        /* Everblush Firefox Theme - userContent.css */
        /* This customizes the web content like the New Tab page */

        @-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
          body {
            background-color: ${colors.background} !important;
            color: ${colors.foreground} !important;
          }

          /* New Tab Page - top sites */
          .top-site-outer .top-site-icon {
            background-color: ${colors.black} !important;
          }

          .top-site-outer .title {
            color: ${colors.foreground} !important;
          }

          .top-site-outer:hover .top-site-icon {
            box-shadow: 0 0 0 2px ${colors.blue} !important;
          }

          /* Search bar */
          .search-wrapper input {
            background-color: ${colors.brightBlack} !important;
            color: ${colors.foreground} !important;
            border: 1px solid ${colors.blue} !important;
          }

          .search-wrapper .search-button {
            color: ${colors.blue} !important;
          }
        }

        /* Customize internal Firefox pages */
        @-moz-document url-prefix("about:") {
          body, html {
            background-color: ${colors.background} !important;
            color: ${colors.foreground} !important;
          }

          a {
            color: ${colors.blue} !important;
          }

          button {
            background-color: ${colors.black} !important;
            color: ${colors.foreground} !important;
            border: 1px solid ${colors.blue} !important;
          }

          button:hover {
            background-color: ${colors.brightBlack} !important;
          }

          input, select, textarea {
            background-color: ${colors.brightBlack} !important;
            color: ${colors.foreground} !important;
            border: 1px solid ${colors.cyan} !important;
          }
        }
      '';

      # Extensions - using direct URLs instead of NUR
      # If you want to use NUR for extensions, you'll need to configure it properly
      # For now, we'll just include a note to install them manually
    };
  };

  # Add a script to install the Everblush Firefox theme as a temporary extension
  home.file.".local/bin/install-firefox-everblush.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Create a temporary directory for the theme
      THEME_DIR=$(mktemp -d)

      # Create the manifest.json file
      cat > "$THEME_DIR/manifest.json" << EOF
      {
        "manifest_version": 2,
        "name": "Everblush Theme",
        "version": "1.0",
        "description": "A dark and comfortable theme based on the Everblush color scheme",
        "author": "Stamno",
        "theme": {
          "colors": {
            "frame": "${colors.background}",
            "tab_background_text": "${colors.foreground}",
            "tab_text": "${colors.foreground}",
            "tab_line": "${colors.blue}",
            "tab_loading": "${colors.blue}",
            "tab_selected": "${colors.black}",
            "tab_background_separator": "${colors.black}",
            "bookmark_text": "${colors.foreground}",
            "toolbar": "${colors.black}",
            "toolbar_field": "${colors.brightBlack}",
            "toolbar_field_text": "${colors.foreground}",
            "toolbar_field_border": "${colors.cyan}",
            "toolbar_field_focus": "${colors.background}",
            "toolbar_field_text_focus": "${colors.foreground}",
            "toolbar_field_border_focus": "${colors.blue}",
            "toolbar_field_highlight": "${colors.blue}",
            "toolbar_field_highlight_text": "${colors.background}",
            "toolbar_bottom_separator": "${colors.black}",
            "toolbar_top_separator": "${colors.black}",
            "toolbar_vertical_separator": "${colors.brightBlack}",
            "button_background_hover": "${colors.brightBlack}",
            "button_background_active": "${colors.brightBlack}",
            "icons": "${colors.foreground}",
            "icons_attention": "${colors.yellow}",
            "popup": "${colors.black}",
            "popup_text": "${colors.foreground}",
            "popup_border": "${colors.blue}",
            "popup_highlight": "${colors.blue}",
            "popup_highlight_text": "${colors.background}",
            "ntp_background": "${colors.background}",
            "ntp_text": "${colors.foreground}",
            "sidebar": "${colors.black}",
            "sidebar_text": "${colors.foreground}",
            "sidebar_highlight": "${colors.blue}",
            "sidebar_highlight_text": "${colors.background}",
            "sidebar_border": "${colors.brightBlack}"
          }
        }
      }
      EOF

      # Create a simple icon for the theme
      mkdir -p "$THEME_DIR/icons"

      # Open Firefox and install the theme
      echo "=== Everblush Firefox Theme ==="
      echo "Theme files created at: $THEME_DIR"
      echo ""
      echo "To install the theme:"
      echo "1. Open Firefox"
      echo "2. Go to about:debugging"
      echo "3. Click 'This Firefox'"
      echo "4. Click 'Load Temporary Add-on'"
      echo "5. Navigate to $THEME_DIR and select manifest.json"
      echo ""
      echo "Note: This will install the theme temporarily. It will be removed when Firefox is closed."

      # Option to open Firefox to the debugging page
      read -p "Would you like to open Firefox to the debugging page now? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        firefox "about:debugging#/runtime/this-firefox" &
      fi
    '';
  };

  # Add Firefox to the list of installed packages
  home.packages = with pkgs; [
    firefox-bin
  ];
}
