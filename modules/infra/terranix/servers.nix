{ nixosConfigurations, ... }:
{
  compute.instances.minecraft = {
    name = "minecraft";
    requirements = {
      cores = 2;
      mem = 4;
    };
    nixos = {
      enable = true;
      config = nixosConfigurations.minimal;
    };
  };
}
