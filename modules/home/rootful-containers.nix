{ config, pkgs, ... }:

{
  home.shellAliases = {
    nerdctl = "sudo nerdctl";
  };
}
