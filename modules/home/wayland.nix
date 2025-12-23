{ homeModules, pkgs, ... }:
{
  imports = with homeModules; [
    # kanshi
    tofi
    noctalia
  ];

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    xwayland-satellite
  ];

  programs.noctalia-shell = {
    enable = true;
  };
}
