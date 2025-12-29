{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mcman
    moonlight-qt
    prismlauncher
  ];
}
