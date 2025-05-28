{
  description = "Home Manager configuration of polen";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vimix-flake = {
      url = "github:Polensky/vimix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    mkHomeConfig = machineModule: system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
          overlays = [
            (final: prev: {
              neovim = inputs.vimix-flake.packages.${system}.default;
            })
          ];
        };

        modules = [
          ./modules
          machineModule
        ];

        extraSpecialArgs = {inherit system inputs;};
      };
  in {
    homeConfigurations."polen@xps13" = mkHomeConfig ./devices/xps13.nix "x86_64-linux";
    homeConfigurations."polen@pinephone" = mkHomeConfig ./devices/pinephone.nix "aarch64-linux";
    homeConfigurations."charles@mbp-m4" = mkHomeConfig ./devices/mbp-m4.nix "aarch64-darwin";
    homeConfigurations."charles@mbp-intel" = mkHomeConfig ./devices/mbp-intel.nix "x86_64-darwin";
  };
}
