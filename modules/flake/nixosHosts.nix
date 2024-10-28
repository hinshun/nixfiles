{ self
, config
, lib
, profiles
, withSystem
, ...
}:
let
  inherit (self)
    homeModules
    nixosModules
    palettes
  ;

  inherit (lib)
    mkOption
    types
  ;

  mkHost = { system, module }:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);

      nixosBase = {
        _module.args = {
          inherit profiles;
          pkgs = lib.mkForce pkgs;
        };
      };

      homeManagerBase = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = {
            inherit homeModules palettes;
          };
        };
      };

    in lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixosModules; };
      modules = [
        nixosBase
        nixosModules.home-manager
        homeManagerBase
        module
      ];
    };

  hostsFor = system:
    lib.mapAttrs
      (_: module: mkHost { inherit system module; })
      config.nixosHosts;

  nixosConfigurations = hostsFor "x86_64-linux";

  packagesFor = system:
    lib.mapAttrs
      (_: nixosSystem: nixosSystem.config.system.build.toplevel)
      (hostsFor system);

in {
  options.nixosHosts = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
  };

  config = {
    flake = { inherit nixosConfigurations; };

    perSystem = { system, ... }: {
      packages = packagesFor system;
    };
  };
}
