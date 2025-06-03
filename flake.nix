{
  description = "Yusei's Nix configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = { darwin, nixpkgs, home-manager,neovim-nightly-overlay, ... }:
    let
      username = "yuseiito";
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      nixpkgs = {
        overlays =[
        neovim-nightly-overlay.overlays.default
      ];
      };
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      darwinConfigurations = {
        belle = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/belle
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/darwin;
            }
          ];

        };
      };
    };
}

