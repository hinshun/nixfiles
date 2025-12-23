{ homeModules, pkgs, ... }:
{
  imports = with homeModules; [
    # hyprland
    kanshi
    # tofi
    # waybar
  ];

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];

  # Enable lightweight notification daaemon for Wayland.
  # services.mako.enable = true;
}
