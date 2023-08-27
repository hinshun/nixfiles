{ self, lib, withSystem, profiles, ... }:
let
  inherit (self)
    homeModules
    nixosModules
  ;

  hostSystem = { system, module }:
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
            inherit homeModules;
          };
        };
      };

    in lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixosModules; };
      modules = [
        module
        nixosBase
        nixosModules.home-manager
        homeManagerBase
      ];
    };

  framework = system: hostSystem {
    inherit system;
    module = ./framework;
  };

in {
  flake.nixosConfigurations.framework = framework "x86_64-linux";

  perSystem = { system, ... }: {
    packages.framework = (framework system).config.system.build.toplevel;
  };
}
