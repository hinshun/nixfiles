{ config, lib, pkgs, ... }:

{
  imports = [ ./programs/aider.nix ];

  programs.aider = {
    enable = true;
  };
}
