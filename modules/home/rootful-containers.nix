{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.containers.rootful;
in {
  options.home.containers.rootful = {
    enable = mkEnableOption "rootful container support";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      nerdctl = "sudo nerdctl";
    };
  };
}
