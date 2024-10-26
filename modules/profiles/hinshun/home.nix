{ config, pkgs, homeModules, ... }:
let
  containerd = {
    inherit (config.virtualisation.containerd.rootless)
      nsenter
    ;
  };

in {
  imports = with homeModules; [
    basicDotfiles
    direnv
    gaming
    helix
    nix-snapshotter
    starship
    streaming
    wayland
    # zellij
    zsh
  ];

  home = {
    username = "hinshun";
    homeDirectory = "/home/hinshun";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  programs.google-chrome = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    profiles.hinshun = {
      settings = {
        "dom.security.https_only_mode" = true;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Edgar Lee";
    userEmail = "edgarhinshunlee@gmail.com";
  };

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

  # Perform systemd service updates automatically, will eventually become the
  # new default.
  systemd.user.startServices = "sd-switch";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    cargo
    containerd.nsenter
    discord
    gcc
    git-lfs
    go
    nerdctl
    obsidian
    rustc
    vlc
    weechat
    zoom-us
  ];

  # home.shellAliases = {
  #   nerdctl = "sudo nerdctl";
  # };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hinshun/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
  };
}
