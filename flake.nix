{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ nixpkgs, aerothemeplasma-nix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
      ];
    };
  };
}
