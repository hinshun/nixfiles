{ self, lib, withSystem, profiles, ... }:
let
  inherit (self)
    homeModules
    nixosModules
  ;

  hostSystem = { system, module, profile }:
    let
      pkgs' = withSystem system ({ pkgs', ... }: pkgs');

    in lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixosModules; };
      modules = [
        { _module.args.pkgs = lib.mkForce pkgs'; }
        module
        nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            users.hinshun = profile;
            extraSpecialArgs = {
              inherit homeModules;
            };
          };
        }
      ];
    };

  framework = system: hostSystem {
    inherit system;
    module = ./framework;
    profile = profiles.hinshun;
  };

in {
  flake.nixosConfigurations.framework = framework "x86_64-linux";

  perSystem = { system, ... }: {
    packages.framework = (framework system).config.system.build.toplevel;
  };
}
