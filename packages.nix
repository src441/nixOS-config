{ config, pkgs, ...}:

{
 programs.steam.enable = true;
 programs.firefox.enable = true;

 environment.systemPackages = with pkgs;  [
   fastfetch
   ncdu
   i2c-tools
   pciutils
   aria2
   kdePackages.sddm-kcm
   apparmor-parser
   apparmor-utils
 ];

 users.users.cris441.packages = with pkgs;  [
   vesktop
   vlc
   libreoffice-qt
   krita
   unciv
   lutris
   luanti
   # rpcs3 - broken packages :/
   shadps4
   mame
   bitwarden-desktop
   uget
   qbittorrent
   stremio-linux-shell
   supertuxkart
   zeroad
   vinegar
   supertux
   prismlauncher
   the-powder-toy
   openttd
   mindustry
   osu-lazer-bin
   flightgear
   kdePackages.plasma-browser-integration
 ];

 # Exclude KDE apps
 environment.plasma6.excludePackages = with pkgs.kdePackages; [
   qrca
   kate
   okular
   gwenview
   elisa
   kwalletmanager
 ];
}
