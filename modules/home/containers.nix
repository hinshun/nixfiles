{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.containers;

in mkMerge [
  {
    options.home.containers = {
      enable = mkEnableOption "container support";

      type = mkOption {
        type = types.enum [ "rootless" "rootful" ];
        default = "rootless";
        description = "Whether to use rootless or rootful containers";
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        nerdctl
      ];
    };
  }
  (mkIf cfg.enable (mkMerge [
    (mkIf (cfg.type == "rootless") {
      imports = [ ./rootless-containers.nix ];
    })
    (mkIf (cfg.type == "rootful") {
      imports = [ ./rootful-containers.nix ];
    })
  ]))
]
