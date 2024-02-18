{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza";
      cdg = "cd $(find -L ~/git -maxdepth 2 -mindepth 2 | fzf --reverse --height 12)";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    eza
  ];
}
