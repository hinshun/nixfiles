{ lib, ... }:
{
  nixosHosts.framework = ./framework/configuration.nix;
}
