{ lib, ... }:
{
  flake.homeModules = lib.readModules ./.;
}
