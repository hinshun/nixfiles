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

    agenix = {
      url = "github:ryantm/agenix";      
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Private repository holding *.age secrets.
    secrets = {
      url = "github:hinshun/secrets";
      flake = false;
    };

    # nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter?ref=feature/buildkit";
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
