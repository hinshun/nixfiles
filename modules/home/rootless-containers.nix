{ config, pkgs, ... }:

let
  containerd = {
    inherit (config.virtualisation.containerd.rootless)
      nsenter
    ;
  };

in {
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
    containerd.nsenter
  ];
}
