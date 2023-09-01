{ pkgs, homeModules, ... }:
{
  imports = with homeModules; [
    basicDotfiles
    # nix-snapshotter
  ];

  home = {
    username = "hinshun";
    homeDirectory = "/home/hinshun";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  programs.firefox = {
    enable = true;
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bat
    direnv
    discord
    fzf
    htop
    kazam
    vlc
    weechat
    zoom-us
  ];

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
