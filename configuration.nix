{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.pam.loginLimits = [
  { domain = "@wheel"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };
 
  fonts.fontconfig = {
  enable = true;
  antialias = true;
  includeUserConf = false;  
  subpixel.rgba = "none";
  subpixel.lcdfilter = "none"; 
  hinting.enable = false;
  };

  
  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.new_feature;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "i2c-dev" "i2c-i801" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  security.apparmor = {
    enable = false; # Enable this when AppArmor support is good
  };
  services.dbus.apparmor = "enabled";
 
  networking.hostName = "nixos"; 
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [
  "1.1.1.1"
  "1.0.0.1"
  "2606:4700:4700::1111"
  "2606:4700:4700::1001"
  ];
  networking.networkmanager.dns = "none";
  
  
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
    
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = true;
  
  time.timeZone = "Europe/Lisbon";

  i18n.defaultLocale = "en_US.UTF-8";

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

  services.xserver.enable = false;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "pt";
    # variant = "nodeadkeys";
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
  };

  services.flatpak.enable = true;
  programs.nix-ld.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";

}
