{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.containers.rootless;
in {
  options.home.containers.rootless = {
    enable = mkEnableOption "rootless container support";
  };

  config = mkIf cfg.enable {
    virtualisation.containerd.rootless = {
      enable = true;
      nixSnapshotterIntegration = true;
    };

    services.nix-snapshotter.rootless = {
      enable = true;
    };

    services.buildkit.rootless = {
      enable = true;
    };

    home.packages = with pkgs; [
      config.virtualisation.containerd.rootless.nsenter
    ];
  };
}
