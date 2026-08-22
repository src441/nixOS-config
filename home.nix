{ config, pkgs, ... }:

{
  home.username = "cris441";
  home.homeDirectory = "/home/cris441";
  nix.package = pkgs.nix;
  home.stateVersion = "26.05"; # Please read the comment before changing.
  xdg.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  home.packages = [
      pkgs.kdePackages.kate
      pkgs.vesktop
      pkgs.prismlauncher
      pkgs.vinegar
   ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "cris441";
      email = "cris441git@gmail.com";
    };
  };
  
  home.file = {
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
