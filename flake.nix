{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    tether = {
      url = "github:hflsmax/tether";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, tether, ... }: {
    nixosConfigurations.apple = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        tether.nixosModules.default
      ];
    };
  };
}
