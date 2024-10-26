{
  description = "Personal nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-snapshotter = {
      url = "git+file:/home/hinshun/git/pdtpartners/nix-snapshotter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs.lib = nixpkgs.lib.extend(final: prev:
        import ./lib { lib = final; }
      );
    } {
      systems = [ "x86_64-linux" ];
      imports = [ ./modules ];
      flake.nixpkgs = nixpkgs;
    };
}
