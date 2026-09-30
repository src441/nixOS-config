{ config, pkgs, ...}:

{
 programs.steam.enable = true;
 programs.firefox.enable = true;

 environment.systemPackages = with pkgs;  [
   fastfetch
   unrar
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
   vscode
   vscode-runner
   godot
   unciv
   lutris
   luanti
   rpcs3
   (pkgs.rpcs3.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "RPCS3";
      repo = "rpcs3";
      rev = "fc93d932c8560f763f5223c0a4165cc53bceeb3f";
      hash = "sha256-dOwpDQyv+nxOxL+OJeLQfYAbKnA3MGf5Ash5BOH3FE4="; 
    };
   }))
   rusty-psn-gui
   shadps4
   shadps4-qtlauncher
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
