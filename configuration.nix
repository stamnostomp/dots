# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:

{

# enable experimental features
nix.settings.experimental-features = [ "flakes" "nix-command" ];
# Enable OpenGL
  hardware.bluetooth.enable = true;
    nixpkgs.config.allowUnfree = true;

  hardware.opengl = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  
};
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
	<home-manager/nixos> 
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Enable the X11 windowing system.

  services.xserver = {
          enable = true;
          xkb.layout = "us";
          windowManager.bspwm.enable = true;
          #windowManager.bspwm.configFile = "/home/user/stamno/.config/dots/bspwm/bspwmrc";
          #windowManager.bspwm.sxhkd.configFile = "/home/user/stamno/.config/dots/sxhkd/sxhkdrc";
          displayManager.lightdm = {
            enable = true;
            greeters.gtk = {
              enable = true;
              theme.name = "gruvbox-dark";

              iconTheme.name = "gruvbox-dark";
            };
          };

  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;


  # Configure keymap in X11
#  services.xserver = {
#    layout = "gb";
 #   xkbVariant = "";
  #};

  # Configure console keymap
  console.keyMap = "uk";
 fonts.packages= [
   pkgs.powerline-fonts
   pkgs.ibm-plex
   pkgs.terminus_font_ttf
   pkgs.iosevka
   pkgs.cherry
   pkgs.cozette
   pkgs.siji
   pkgs.font-awesome
   pkgs.emacs-all-the-icons-fonts
   pkgs.dina-font
  ];


  # Enable CUPS to print documents.
  services.printing.enable = true;
  #Enable libvirtd for gnome boxes
  virtualisation.libvirtd.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.systemWide = true;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
 programs.fish.enable = true;
  users.users.stamno = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "stamno";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #fonts
      ibm-plex

	#browsers
	brave
	chromium
 firefox
 #qutebrowser

#trezor
trezor-udev-rules
trezor-suite
trezord
  vesktop
  signal-desktop
	#games

	heroic
	steam
	protontricks
	lutris
	wine
	bottles
	dxvk
	#tools
	protonvpn-gui
	#gnome
	gnome.gnome-software
        gnome.gnome-boxes
	#libvirtd needed for boxes
	libvirt
  #sound
  pulsemixer
  alsa-utils
  #spotifyd
  spotify
  spicetify-cli
  #spotify-tui
  fastfetch



	#dev
darktable
starship
eza
	nodejs		 
	godot_4
	unityhub
	btop
	pv
# themes
gruvbox-dark-gtk
gruvbox-dark-icons-gtk
	#emacs
#rust
rustc
  #haskell
  stylish-haskell
  haskellPackages.stack
  haskell-language-server
	haskellPackages.hoogle
	haskellPackages.cabal-install
  ghc
((emacsPackagesFor emacs-unstable).emacsWithPackages
(epkgs: [ epkgs.vterm ]))
      ## Doom dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      gnutls              # for TLS connectivity

      ## Optional dependencies
      fd                  # faster projectile indexing
      imagemagick         # for image-dired
      
      pinentry-emacs   # in-emacs gnupg prompts
      zstd                # for undo-fu-session/undo-tree compression

      ## Module dependencies
      # :checkers spell
      (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
      # :tools editorconfig
      editorconfig-core-c # per-project style config
      # :tools lookup & :lang org +roam
      sqlite
      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium
      # :lang beancount
      #everywhere deps
      cmake
      
	    xorg.xwininfo
	    xdotool
	    xclip
      libtool
	    binutils       # native-comp needs 'as', provided by this
      #docker format tools
      dockfmt
      #csharp
      # TODO
      # desktop programs
      polybar
      arandr
      autorandr
      android-studio
      sxhkd
      picom
      feh
      rofi
      rofi-power-menu
      rofi-bluetooth
      rofi-calc
      rofi-emoji
      rofi-pulse-select
      flameshot


      #markdown
      multimarkdown
      #nix formating
      nixfmt
      # pure scritp tidy
      nodePackages_latest.purs-tidy
      # paser and formater
      shfmt


    ];
  };

users.users.eve.isNormalUser = true;
home-manager.users.stamno = { pkgs, ... }: {
  home.packages = [
     ];
 
  programs.fish.enable = true;
#  interactiveShellInit = "eat piss or die trying";
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.05";
};

  # Allow unfree packages

   nixpkgs.overlays = [
	(import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
 ];

    # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
    wget
    git
    bind
    cached-nix-shell
    gnumake
    unzip
  ];

		



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.emacs.package = pkgs.emacs-unstable;
  services.emacs.enable = true;
  services.blueman.enable = true;
 # enable the OpenSSH daemon.
  # services.openssh.enable = true;
   networking.firewall = {
	enable = true;
        allowedUDPPortRanges = [
		{ from = 1714; to = 1764;}
	];
	allowedTCPPortRanges = [
		{ from = 1714; to = 1764;}
	];
  allowedTCPPorts = [57621];
  allowedUDPPorts = [5353];
   };

    # this value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
