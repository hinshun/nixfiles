{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = "$directory$git_branch$git_state$git_status$cmd_duration$line_break$direnv$character";

      directory = {
        truncation_length = 100;
        truncate_to_repo = false;
        style = "blue";
      };

      # direnv = {
      #   disabled = false;
      # };

      character = {
        success_symbol = "[ツ](bold green)";
        error_symbol = "[ツ](bold red)";
        vimcmd_symbol = "[ツ](bold green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = ''
          ([$state( $progress_current/$progress_total)]($style))
        '';
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };
}
