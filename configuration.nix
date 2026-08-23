{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
 
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

  xdg.portal = {
  enable = true;
  extraPortals = [ 
    pkgs.kdePackages.xdg-desktop-portal-kde
    pkgs.xdg-desktop-portal-gtk 
  ];
  config = {
    common = {
      default = [ "kde" ];
    };
  };
};

 environment.sessionVariables = {
  XDG_DATA_DIRS = ["$HOME/.nix-profile/share"];
};

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    qrca
    gwenview
    okular
    elisa
    kwalletmanager
  ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";

  i18n.defaultLocale = "pt_PT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  services.flatpak.enable = true;
 
  services.xserver.enable = false;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "pt";
    variant = "nodeadkeys";
  };

  console.keyMap = "pt-latin1";

  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users."cris441" = {
    isNormalUser = true;
    description = "cris441";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      lutris
      steam
      wineWow64Packages.staging
      winetricks
      ncdu
    ]; 
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fish
    fastfetch
    neovim
    btdu
    kdePackages.sddm-kcm
    git
    unrar
  ];

  nixpkgs.config.permittedInsecurePackages = [
  "electron-40.10.5" # remove this once winboat update their electron version
  ];
  system.stateVersion = "26.05"; # Did you read the comment?
}
