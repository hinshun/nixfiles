{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza";
      cdg = "cd $(find -L ~/git -maxdepth 2 -mindepth 2 | fzf --reverse --height 12)";
    };
    envExtra = ''
      export HCLOUD_TOKEN=$(cat /run/agenix/hetzner-cloud)
      export ANTHROPIC_API_KEY=$(cat /run/agenix/anthropic-api)
      export OPENROUTER_API_KEY=$(cat /run/agenix/openrouter-api)
      export OPENAI_API_KEY=$(cat /run/agenix/openai-api)
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    eza
  ];
}
