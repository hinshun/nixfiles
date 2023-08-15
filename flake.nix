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
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    let
      lib = nixpkgs.lib // (import ./lib);
      # parts = lib.readTree { path = ./.; };
      parts = {
        foo = {
          __functor = _: import ./foo;
          framework = import ./nixos/hosts/framework;
        };
        home = {
          profiles.hinshun = import ./home/profiles/hinshun.nix;
        };
      };
    in flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = { inherit parts; };
    } {
      systems = [ "x86_64-linux" ];
      # imports = with parts; [
      #   home
      #   nixos.hosts
      # ];
      imports = [
        parts.foo
      ];
    };
}
