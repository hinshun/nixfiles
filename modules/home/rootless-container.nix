{ config, pkgs, ... }:

{
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
    nerdctl
    containerd.nsenter
  ];

  # Uncomment if you want to use the alias
  # home.shellAliases = {
  #   nerdctl = "sudo nerdctl";
  # };
}
