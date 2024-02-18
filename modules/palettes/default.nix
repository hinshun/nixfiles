{ lib, ... }:
{
  flake.palettes = lib.readModules ./.;
}
