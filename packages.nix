{ config, pkgs, ...}:

{
 programs.steam.enable = false;
 programs.firefox.enable = true;
 
 environment.systemPackages = with pkgs;  [
   fastfetch
   unrar
   ncdu
   gpaste
   i2c-tools
   pciutils
   aria2
 ];

 users.users.cris441.packages = with pkgs;  [
   vesktop
   vlc
   lutris
   luanti
   uget
   qbittorrent
   stremio-linux-shell
   vinegar
   prismlauncher
   the-powder-toy
   mindustry
   osu-lazer-bin
 ];
}
