# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/stylix.nix
    ];

  # Enable flakes feature
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable hard link for duplicated files to save space
  nix.settings.auto-optimise-store = true;
  # Enable garbage collection weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Add CachyOS kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # Enable AMD overdrive
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xfffd7fff" ];
  # Add kernel module for fan controller
  boot.kernelModules = [ "nct6775" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  # Enable limine as bootloader
  boot.loader.limine.enable = true;
  boot.loader.limine.style.wallpapers = [ ];
  # Limit the number of generations to keep
  boot.loader.limine.maxGenerations = 10;
  # Add Windows entry to bootloader
  boot.loader.limine.extraEntries = ''
    /Windows
      protocol: efi
      path: uuid(7677f76f-28ca-4091-90d0-e84647eee9b4):/EFI/Microsoft/Boot/bootmgfw.efi
  '';
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Graphics support?
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Scheduler settings
  services.scx = {
    enable = true;
    package = pkgs.scx_git.full;
    scheduler = "scx_lavd";
    extraArgs = [ "--autopilot" ];
  };

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # Enable ly as display manager
  services.displayManager.ly.enable = true;

  # TODO Must research what they do, tweak if issues arise
  environment.variables = {
    #XDG_CURRENT_DESKTOP = "Hyprland";
    #XDG_SESSION_TYPE = "wayland";
    #QT_QPA_PLATFORM = "wayland";
    #GDK_BACKEND = "wayland,x11";
    #NIXOS_OZONE_WL = "1";
    #ELECTRON_OZONE_PLATFORM_HINT = "auto";
    #MOZ_ENABLE_WAYLAND = "1";
    #WLR_NO_HARDWARE_CURSORS = "1";
    #SDL_VIDEODRIVER = "wayland";
  };

  # TODO Must research what they do, tweak if issues arise
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      #xdg-desktop-portal-gtk
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."vee" = {
    isNormalUser = true;
    description = "vee";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #thunderbird
    ];
    # Set default shell for user
    shell = pkgs.fish;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Install Git
  programs.git.enable = true;

  # Install Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Install fish
  programs.fish.enable = true;

  # Install waybar
  programs.waybar.enable = true;

  # Install neovim
  programs.neovim.enable = true;

  # Install LACT
  services.lact.enable = true;

  # Install yazi
  programs.yazi.enable = true;

  # Install zoxide
  programs.zoxide.enable = true;

  # Install bat
  programs.bat.enable = true;

  # Install Steam and other gaming tools
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Install Sunshine
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Enable virtualisation
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Enable flatpaks
  services.flatpak.enable = true;

  # Enable appimages
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Install mesa git
  chaotic.mesa-git.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    distrobox
    hyprpaper
    kdePackages.dolphin
    dunst
    eza
    fan2go
    fastfetch
    fzf
    gcc
    p7zip
    btop
    rar
    ghostty
    gnumake
    home-manager
    lm_sensors
    mangohud
    ripgrep
    stow
    tealdeer
    unzip
    vesktop
    wget
    wl-clipboard
    wofi
    pavucontrol
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  systemd.services.fan2go = {
    enable = true;
    description = "Advanced Fan Control program";
    wantedBy = [ "multi-user.target" ];
    after = [ "lm-sensors.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml --no-style";
      Restart = "always";
      RestartSec = "1s";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
