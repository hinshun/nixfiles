{ self, lib, profiles, config, withSystem, ... }:
let
  inherit (self)
    nixosModules
    homeModules
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
          extraSpecialArgs = { inherit homeModules; };
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
  };

  config = {
    flake = { inherit nixosConfigurations; };

    perSystem = { system, ... }: {
      packages = packagesFor system;
    };
  };
}
