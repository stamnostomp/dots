# [Hyprland] Everblush

## Details
- **OS**: NixOS Unstable
- **WM**: Hyprland
- **Terminal**: Alacritty / Kitty
- **Shell**: Fish + Bash (with starship prompt)
- **Editor**: Doom Emacs (`doom-everblush-theme`)
- **Bar**: Waybar
- **Launcher**: Wofi
- **File Manager**: PCManFM / Dolphin / Thunar
- **GTK Theme**: [Everblush GTK](https://github.com/Everblush/gtk)
- **Icons**: Papirus-Dark
- **Cursor**: macOS-BigSur
- **Font**: Dina (pixelsize=12, no antialiasing)
- **Notification**: Dunst
- **Screenshot Tool**: Grimblast
- **Audio**: pulsemixer + easyeffects

## Screenshot
[Screenshot](preview.png)

## Features
- Declarative NixOS configuration with flakes
- Modular home-manager setup
- Custom Everblush color scheme across all applications
- Seamless Doom Emacs integration with native compilation
- Automatic theme consistency across GTK applications
- Custom waybar configuration with powerline styling
- Two monitor support (3440x1440@144Hz + 1920x1080@75Hz)

## Highlights
- **Doom Emacs**: Auto-configured with custom `doom-everblush-theme` and syncs from my [personal repo](https://github.com/stamnostomp/doom-d)
- **Performance**: Native Doom compilation, hardware-accelerated Wayland
- **Shell**: Fish with emacs vterm integration + custom nix-shell prompts
- **Monitor**: Proper positioning for ultrawide + secondary display

## Key Bindings
- `SUPER + Return`: Terminal
- `SUPER + Space`: App Launcher
- `SUPER + E`: Doom Emacs
- `SUPER + W`: Web Browser
- `ALT + S`: Screenshot region

## Dotfiles

```nix
inputs.everblush-gtk.url = "github:Everblush/gtk";
```

