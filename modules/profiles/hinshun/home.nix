{ config, pkgs, homeModules, ... }:

{
  imports = with homeModules; [
    aider
    basicDotfiles
    direnv
    gaming
    helix
    nix-snapshotter
    rootless-container
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

  # Perform systemd service updates automatically, will eventually become the
  # new default.
  systemd.user.startServices = "sd-switch";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    cargo
    discord
    gcc
    git-lfs
    go
    obsidian
    pass
    rustc
    vlc
    weechat
    zoom-us
  ];
}
