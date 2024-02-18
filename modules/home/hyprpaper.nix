{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
  ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    ipc = off
    preload = /path/to/image.png
    wallpaper = /path/to/image.png
  '';
}
