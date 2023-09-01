let
  # inherit (self)
  #   homeModules
  # ;

  # inherit (inputs.home-manager.lib)
  #   homeManagerConfiguration
  # ;

  hinshun = ./hinshun/home.nix;

in {
  _module.args.profiles = {
    inherit hinshun;
  };

  # perSystem = { pkgs, ... }:
  #   let
  #     hinshun = homeManagerConfiguration {
  #       inherit pkgs;
  #       modules = [ hinshun ];
  #       extraSpecialArgs = { inherit homeModules; };
  #     };

  #   in {
  #     # legacyPackages.homeConfigurations = { inherit hinshun; };
  #     packages.hinshun = hinshun.activationPackage;
  #   };
}
