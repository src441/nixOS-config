{
  description = "my flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
  };

  outputs = { self, nixpkgs, nixpkgs-master, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs-master; };

        modules = [
          ./hardware-configuration.nix 
          ./configuration.nix          
          ./packages.nix
          ({ nixpkgs-master, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                master = import nixpkgs-master {
                  system = prev.system;
                  config = prev.config;
                };
              })
            ];
          })
        ];
      };
    };
  };
}
