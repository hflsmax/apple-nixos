{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-grafana.url = "github:NixOS/nixpkgs/47c1824c261a343a6acca36d168a0a86f0e66292";
    tether = {
      url = "github:hflsmax/tether";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixpkgs-stable, nixpkgs-grafana, tether, ... }: {
    nixosConfigurations.apple = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
        pkgs-stable = import nixpkgs-stable { system = "x86_64-linux"; config.allowUnfree = true; };
        pkgs-grafana = import nixpkgs-grafana { system = "x86_64-linux"; };
      };
      modules = [
        ./configuration.nix
        tether.nixosModules.default
      ];
    };
  };
}
