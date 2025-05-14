# modules/home/editors/emacs-everywhere.nix
{ config, lib, pkgs, ... }:

{
  # Add required dependencies
  home.packages = with pkgs; [
    # X utilities (needed even on Wayland for some operations)
    xdotool
    xorg.xprop
    xorg.xwininfo
    xclip

    # Wayland utilities
    wl-clipboard
    wtype
    slurp
    grim

    # Other dependencies
    procps
    libnotify
    jq  # For JSON parsing in our script
  ];

  # Hyprland integration
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      # Add this to existing bindings
      "$mod SHIFT, semicolon, exec, ${config.home.homeDirectory}/.local/bin/emacs-everywhere-launcher.sh"
    ];

    windowrule = [
      # Window rules for Emacs Everywhere
      "float, title:^(emacs-everywhere)$"
      "center, title:^(emacs-everywhere)$"
      "size 80% 70%, title:^(emacs-everywhere)$"
      "animation popin, title:^(emacs-everywhere)$"
    ];
  };

  # Create launcher script
  home.file.".local/bin/emacs-everywhere-launcher.sh" = {
    executable = true,
    text = ''
      #!/usr/bin/env bash

      # Set up environment
      export XMODIFIERS=@im=none  # Disable input methods that might interfere

      # Get the active window information
      if command -v hyprctl >/dev/null 2>&1; then
        # Wayland/Hyprland specific
        active_window=$(hyprctl activewindow -j)
        window_class=$(echo "$active_window" | ${pkgs.jq}/bin/jq -r '.class')
        window_title=$(echo "$active_window" | ${pkgs.jq}/bin/jq -r '.title')
        window_pid=$(echo "$active_window" | ${pkgs.jq}/bin/jq -r '.pid')
      else
        # X11 fallback
        window_id=$(${pkgs.xdotool}/bin/xdotool getactivewindow)
        window_class=$(${pkgs.xorg.xprop}/bin/xprop -id "$window_id" WM_CLASS | cut -d'"' -f2)
        window_title=$(${pkgs.xorg.xprop}/bin/xprop -id "$window_id" WM_NAME | cut -d'"' -f2)
        window_pid=$(${pkgs.xorg.xprop}/bin/xprop -id "$window_id" _NET_WM_PID | awk '{print $3}')
      fi

      # Save info to temporary file
      tmp_info=$(mktemp)
      echo "window_class: $window_class" > "$tmp_info"
      echo "window_title: $window_title" >> "$tmp_info"
      echo "window_pid: $window_pid" >> "$tmp_info"

      # Copy selection to clipboard first
      if command -v wl-copy >/dev/null 2>&1; then
        # Try to get selection - this may not always work depending on the app
        ${pkgs.wtype}/bin/wtype -k ctrl+c
        sleep 0.3
      else
        ${pkgs.xdotool}/bin/xdotool key ctrl+c
        sleep 0.3
      fi

      # Launch emacsclient with proper configuration
      ${pkgs.emacs}/bin/emacsclient -c -F '((name . "emacs-everywhere") (width . 80) (height . 25))' \
        -e "(progn
             (require 'emacs-everywhere)
             (defun ee-custom-app-info ()
               (let* ((info-file \"$tmp_info\")
                      (info-content (with-temp-buffer
                                     (insert-file-contents info-file)
                                     (buffer-string)))
                      (class (when (string-match \"window_class: \\\\(.*\\\\)\" info-content)
                              (match-string 1 info-content)))
                      (title (when (string-match \"window_title: \\\\(.*\\\\)\" info-content)
                              (match-string 1 info-content))))
                 (list :class class :title title :id 0)))
             (setq emacs-everywhere-app-info-function #'ee-custom-app-info)
             (emacs-everywhere))"

      # Clean up
      rm "$tmp_info"
    '';
  };

  # Custom Doom Emacs configuration for Emacs Everywhere
  home.file.".doom.d/modules/tools/emacs-everywhere/config.el" = lib.mkIf (config.modules.doom-emacs.enable or false) {
    text = ''
      ;;; tools/emacs-everywhere/config.el -*- lexical-binding: t; -*-

      (use-package! emacs-everywhere
        :config
        ;; Default to markdown mode
        (setq emacs-everywhere-major-mode-function #'markdown-mode)

        ;; App-specific major modes
        (setq emacs-everywhere-app-classes
              '(("Firefox" . markdown-mode)
                ("firefox" . markdown-mode)
                ("chromium" . markdown-mode)
                ("Google-chrome" . markdown-mode)
                ("Discord" . markdown-mode)
                ("discord" . markdown-mode)
                ("Slack" . markdown-mode)
                ("slack" . markdown-mode)
                ("org.telegram.desktop" . markdown-mode)
                ("Element" . markdown-mode)
                ("Signal" . markdown-mode)
                ("kitty" . text-mode)
                ("Alacritty" . text-mode)
                ("code" . text-mode)))

        ;; Set up hooks for more customization
        (add-hook 'emacs-everywhere-init-hooks
                  (defun +emacs-everywhere-init-h ()
                    ;; Enable line wrapping
                    (visual-line-mode 1)
                    ;; Enable spell checking
                    (when (bound-and-true-p spell-fu-mode)
                      (spell-fu-mode 1))
                    ;; Disable line numbers
                    (display-line-numbers-mode -1)
                    ;; Enable text scaling (bigger text)
                    (text-scale-set 1)
                    ;; Make the frame semi-transparent
                    (set-frame-parameter nil 'alpha '(95 . 90))
                    ;; Add a title
                    (setq header-line-format
                          (format " 📝 Editing text from: %s"
                                  (plist-get emacs-everywhere-app-info :class)))))

        ;; Set up finalization hooks
        (add-hook 'emacs-everywhere-final-hooks
                  (defun +emacs-everywhere-final-h ()
                    ;; Prompt with options
                    (unwind-protect
                        (let ((action (read-char-choice
                                      "Action: [s]end, [c]ancel, [k]eep frame, [d]etach frame "
                                      '(?s ?c ?k ?d))))
                          (pcase action
                            ('?s (emacs-everywhere-finish))
                            ('?c (emacs-everywhere-abort))
                            ('?k nil)
                            ('?d (progn
                                   (remove-hook 'delete-frame-functions
                                                #'emacs-everywhere-finish-or-abort-frame)
                                   (set-frame-parameter (selected-frame) 'name "detached")
                                   (display-buffer-pop-up-frame (current-buffer) nil)))))
                      (unless (memq (selected-frame) (frame-list))
                        (with-current-buffer (get-buffer-create "◐ *emacs-everywhere* ◑")
                          (insert (buffer-string)))))))
      )

      ;; Add keybindings to make editing easier
      (map! :map emacs-everywhere-mode-map
            "C-c C-c" #'emacs-everywhere-finish
            "C-c C-k" #'emacs-everywhere-abort
            "C-c C-d" (cmd! (remove-hook 'delete-frame-functions
                                        #'emacs-everywhere-finish-or-abort-frame)
                            (set-frame-parameter (selected-frame) 'name "detached")
                            (display-buffer-pop-up-frame (current-buffer) nil)))
    '';
  };
}
