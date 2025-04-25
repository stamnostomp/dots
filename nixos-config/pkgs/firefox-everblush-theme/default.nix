{
  lib,
  stdenv,
  writeTextFile,
}:

let
  # Colors from Everblush theme
  colors = {
    background = "#141b1e";
    foreground = "#dadada";
    cursor = "#dadada";
    black = "#232a2d";
    red = "#e57474";
    green = "#8ccf7e";
    yellow = "#e5c76b";
    blue = "#67b0e8";
    magenta = "#c47fd5";
    cyan = "#6cbfbf";
    white = "#b3b9b8";
    brightBlack = "#2d3437";
    brightRed = "#ef7e7e";
    brightGreen = "#96d988";
    brightYellow = "#f4d67a";
    brightBlue = "#71baf2";
    brightMagenta = "#ce89df";
    brightCyan = "#67cbe7";
    brightWhite = "#bdc3c2";
  };

  # Create a manifest.json file
  manifest = writeTextFile {
    name = "manifest.json";
    text = ''
      {
        "manifest_version": 2,
        "name": "Everblush Theme",
        "version": "1.0.0",
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
    '';
  };

  # Create a userChrome.css file
  userChrome = writeTextFile {
    name = "userChrome.css";
    text = ''
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
  };

  # Create a userContent.css file
  userContent = writeTextFile {
    name = "userContent.css";
    text = ''
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
  };

  # Create user.js file
  userJs = writeTextFile {
    name = "user.js";
    text = ''
      // Enable userChrome.css and userContent.css
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Dark mode
      user_pref("browser.theme.toolbar-theme", 0);
      user_pref("browser.theme.content-theme", 0);
      user_pref("browser.in-content.dark-mode", true);
      user_pref("ui.systemUsesDarkTheme", 1);

      // UI customizations
      user_pref("browser.tabs.inTitlebar", 0);
      user_pref("browser.compactmode.show", true);
      user_pref("browser.uidensity", 1);
    '';
  };

in
stdenv.mkDerivation {
  pname = "firefox-everblush-theme";
  version = "1.0.0";

  # No source needed, we're creating files directly
  dontUnpack = true;

  # No build phase needed
  dontBuild = true;

  installPhase = ''
    # Create output directory structure
    mkdir -p $out/share/firefox-everblush-theme
    mkdir -p $out/share/firefox-everblush-theme/chrome
    mkdir -p $out/bin

    # Copy the theme files
    cp ${manifest} $out/share/firefox-everblush-theme/manifest.json
    cp ${userChrome} $out/share/firefox-everblush-theme/chrome/userChrome.css
    cp ${userContent} $out/share/firefox-everblush-theme/chrome/userContent.css
    cp ${userJs} $out/share/firefox-everblush-theme/user.js

    # Create a helper script to install the theme
    cat > $out/bin/install-firefox-everblush-theme << EOF
    #!/usr/bin/env bash

    echo "Everblush Firefox Theme Installer"
    echo "=================================="
    echo ""

    # Find Firefox profile directory
    if [ -d "\$HOME/.mozilla/firefox" ]; then
      FIREFOX_DIR="\$HOME/.mozilla/firefox"

      # Find the default profile
      DEFAULT_PROFILE=\$(grep -E "Default=.+" "\$FIREFOX_DIR/profiles.ini" | cut -d'=' -f2)

      if [ -z "\$DEFAULT_PROFILE" ]; then
        # Try another method to find the profile
        DEFAULT_PROFILE=\$(grep -E "Path=.+\.default" "\$FIREFOX_DIR/profiles.ini" | cut -d'=' -f2 | head -n 1)
      fi

      if [ -n "\$DEFAULT_PROFILE" ]; then
        PROFILE_PATH="\$FIREFOX_DIR/\$DEFAULT_PROFILE"

        # Create chrome directory if it doesn't exist
        mkdir -p "\$PROFILE_PATH/chrome"

        # Copy theme files
        cp ${userChrome} "\$PROFILE_PATH/chrome/userChrome.css"
        cp ${userContent} "\$PROFILE_PATH/chrome/userContent.css"
        cp ${userJs} "\$PROFILE_PATH/user.js"

        echo "Theme installed successfully to: \$PROFILE_PATH"
        echo "Please restart Firefox to apply the theme."
        echo ""
        echo "Would you like to open Firefox now? (y/n)"
        read -r OPEN_FIREFOX

        if [[ \$OPEN_FIREFOX =~ ^[Yy]\$ ]]; then
          firefox &
        fi

      else
        echo "Could not find Firefox default profile."
        echo "Please run Firefox at least once before running this script."
      fi
    else
      echo "Firefox profile directory not found."
      echo "Please make sure Firefox is installed and has been run at least once."
    fi
    EOF

    chmod +x $out/bin/install-firefox-everblush-theme

    # Create a README file
    mkdir -p $out/share/doc/firefox-everblush-theme
    cat > $out/share/doc/firefox-everblush-theme/README.md << EOF
    # Everblush Firefox Theme

    A Firefox theme based on the Everblush color scheme.

    ## Installation

    Run the installer script:

    \`\`\`
    install-firefox-everblush-theme
    \`\`\`

    This will:
    1. Find your Firefox profile
    2. Create a chrome directory if it doesn't exist
    3. Install the userChrome.css and userContent.css files
    4. Configure Firefox to use the theme

    ## Manual Installation

    If the script doesn't work, you can manually install the theme:

    1. Find your Firefox profile directory:
       - Enter \`about:support\` in the Firefox address bar
       - Look for "Profile Directory" and click "Open Directory"

    2. Create a folder called \`chrome\` in this directory if it doesn't exist

    3. Copy these files from \`$out/share/firefox-everblush-theme\`:
       - \`chrome/userChrome.css\` to your profile's \`chrome/userChrome.css\`
       - \`chrome/userContent.css\` to your profile's \`chrome/userContent.css\`
       - \`user.js\` to your profile's \`user.js\`

    4. Restart Firefox

    ## Enabling Custom CSS in Firefox

    If the theme doesn't apply:
    1. Type \`about:config\` in the address bar
    2. Search for \`toolkit.legacyUserProfileCustomizations.stylesheets\`
    3. Set it to \`true\`
    4. Restart Firefox again
    EOF
  '';

  meta = with lib; {
    description = "Everblush Theme for Firefox";
    homepage = "https://github.com/Everblush/gtk";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
