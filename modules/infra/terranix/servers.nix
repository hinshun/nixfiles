{ nixosConfigurations, ... }:
{
  compute.instances.minecraft = {
    name = "minecraft";
    requirements = {
      cores = 8;
      family = "cpu-optimized";
    };
    nixos = {
      enable = true;
      baseConfig = nixosConfigurations.minimal;
    };
  };
}
