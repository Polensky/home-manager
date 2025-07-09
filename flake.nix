{
  description = "Home Manager configuration of polen";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs_25_05.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vimix = {
      url = "github:Polensky/vimix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snsm = {
      url = "github:Polensky/snsm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yt-x = {
      url = "github:Benexl/yt-x";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs_25_05,
    home-manager,
    ...
  } @ inputs: let
    mkHomeConfig = machineModule: system: let
      pkgs_25_05 = import nixpkgs_25_05 {
        inherit system;
        config = {allowUnfree = true;};
      };
    in
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
          overlays = [
            (final: prev: {
              neovim = inputs.vimix.packages.${system}.default;
            })
          ];
        };

        modules = [
          ./modules
          machineModule
        ];

        extraSpecialArgs = {inherit system inputs pkgs_25_05;};
      };
  in {
    homeConfigurations."polen@xps13" = mkHomeConfig ./devices/xps13.nix "x86_64-linux";
    homeConfigurations."polen@pinephone" = mkHomeConfig ./devices/pinephone.nix "aarch64-linux";
    homeConfigurations."charles@mbp-m4" = mkHomeConfig ./devices/mbp-m4.nix "aarch64-darwin";
    homeConfigurations."charles@mbp-intel" = mkHomeConfig ./devices/mbp-intel.nix "x86_64-darwin";
  };
}
