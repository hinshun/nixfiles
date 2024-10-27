{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.containers;
in {
  imports = [
    ./rootless-containers.nix
    ./rootful-containers.nix
  ];

  options.home.containers = {
    enable = mkEnableOption "container support";

    type = mkOption {
      type = types.enum [ "rootless" "rootful" ];
      default = "rootless";
      description = "Whether to use rootless or rootful containers";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        nerdctl
      ];
    }
    (mkIf (cfg.type == "rootless") {
      home.containers.rootless.enable = true;
    })
    (mkIf (cfg.type == "rootful") {
      home.containers.rootful.enable = true;
    })
  ]);
}
