{ homeModules, pkgs, ... }:
{
  imports = with homeModules; [
    hyprland
    # hyprpaper
    tofi
    waybar
  ];

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];
}
