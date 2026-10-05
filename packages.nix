{ config, pkgs, ...}:

{
 programs.steam.enable = true;
 programs.firefox.enable = true;
 
 environment.systemPackages = with pkgs;  [
   fastfetch
   unrar
   htop
   ncdu
   gpaste
   i2c-tools
   pciutils
   aria2
 ];

 users.users.cris441.packages = with pkgs;  [
   vesktop
   vlc
   kdePackages.ark
   p7zip
   rpcs3
   alacarte
   mint-y-icons
   protonplus
   lutris
   luanti
   uget
   qbittorrent
   stremio-linux-shell
   vinegar
   wine-staging
   prismlauncher
   the-powder-toy
   mindustry
   osu-lazer-bin
 ];
}
