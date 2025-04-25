# pkgs/firefox-everblush-theme/flake.nix (updated)
{
  description = "Everblush Theme for Firefox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "firefox-everblush-theme";
            version = "1.0.0";

            dontUnpack = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/share/firefox-theme/chrome
              mkdir -p $out/bin

              # Create userChrome.css
              cat > $out/share/firefox-theme/chrome/userChrome.css << EOF
              /* Everblush Firefox Theme */
              :root {
                --everblush-bg: #141b1e;
                --everblush-fg: #dadada;
                --everblush-black: #232a2d;
                --everblush-bright-black: #2d3437;
                --everblush-blue: #67b0e8;
                --everblush-cyan: #6cbfbf;
              }

              /* Basic theme */
              #main-window {
                background-color: var(--everblush-bg) !important;
                color: var(--everblush-fg) !important;
              }

              .tab-background[selected="true"] {
                background-color: var(--everblush-black) !important;
                border-top: 2px solid var(--everblush-blue) !important;
              }
              EOF

              # Create userContent.css
              cat > $out/share/firefox-theme/chrome/userContent.css << EOF
              /* Everblush Firefox Theme - New Tab */
              @-moz-document url("about:home"), url("about:newtab") {
                body {
                  background-color: #141b1e !important;
                  color: #dadada !important;
                }
              }
              EOF

              # Create user.js preferences file
              cat > $out/share/firefox-theme/user.js << EOF
              // Enable userChrome.css and userContent.css
              user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

              // Set dark mode
              user_pref("browser.theme.toolbar-theme", 0);
              user_pref("browser.theme.content-theme", 0);
              user_pref("browser.in-content.dark-mode", true);
              user_pref("ui.systemUsesDarkTheme", 1);
              EOF

              # Create a better install script that handles permissions
              cat > $out/bin/install-firefox-theme << EOF
              #!/bin/bash

              echo "Everblush Firefox Theme Installer"
              echo "=================================="
              echo ""

              # Find the Firefox profile
              PROFILE_DIR=\$(find ~/.mozilla/firefox -name "*.default*" -type d | head -n 1)

              if [ -z "\$PROFILE_DIR" ]; then
                echo "Firefox profile not found. Is Firefox installed and has been run?"
                exit 1
              fi

              echo "Found Firefox profile: \$PROFILE_DIR"

              # Create a temporary directory in the user's home folder
              TEMP_DIR="\$HOME/firefox-everblush-theme-temp"
              mkdir -p "\$TEMP_DIR"

              # Copy theme files to the temp directory
              cp -r $out/share/firefox-theme/* "\$TEMP_DIR/"

              # Create chrome directory in Firefox profile
              mkdir -p "\$PROFILE_DIR/chrome"

              # Try to copy the files
              if cp "\$TEMP_DIR/chrome/userChrome.css" "\$PROFILE_DIR/chrome/" && \\
                 cp "\$TEMP_DIR/chrome/userContent.css" "\$PROFILE_DIR/chrome/" && \\
                 cat "\$TEMP_DIR/user.js" >> "\$PROFILE_DIR/user.js"; then
                echo "Theme successfully installed!"
              else
                # If copying fails, guide the user to manually copy the files
                echo "Permission error: Unable to automatically copy files."
                echo ""
                echo "To install manually, please run these commands:"
                echo ""
                echo "sudo mkdir -p \"\$PROFILE_DIR/chrome\""
                echo "sudo cp \"\$TEMP_DIR/chrome/userChrome.css\" \"\$PROFILE_DIR/chrome/\""
                echo "sudo cp \"\$TEMP_DIR/chrome/userContent.css\" \"\$PROFILE_DIR/chrome/\""
                echo "sudo cat \"\$TEMP_DIR/user.js\" >> \"\$PROFILE_DIR/user.js\""
                echo "sudo chown -R \$(whoami):\$(whoami) \"\$PROFILE_DIR/chrome\""
                echo "sudo chmod 644 \"\$PROFILE_DIR/chrome/userChrome.css\" \"\$PROFILE_DIR/chrome/userContent.css\""
                echo ""
                echo "Files are available at: \$TEMP_DIR"
                echo "Please restart Firefox after installing."
                exit 1
              fi

              echo "Theme installed! Please restart Firefox to apply the theme."
              echo "If Firefox is already running, close it completely and start it again."

              # Ask if user wants to clean up temp files
              read -p "Do you want to remove temporary files? (y/n): " cleanup
              if [[ \$cleanup =~ ^[Yy]$ ]]; then
                rm -rf "\$TEMP_DIR"
                echo "Temporary files removed."
              else
                echo "Temporary files kept at: \$TEMP_DIR"
              fi
              EOF

              chmod +x $out/bin/install-firefox-theme
            '';
          };
        };
      }
    );
}
