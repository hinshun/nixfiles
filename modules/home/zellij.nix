{ palettes, ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      default_layout = "compact";

      theme = "hinshun";
      themes.hinshun = with palettes.toffee; {
        inherit
          black
          blue
          cyan
          green
          magenta
          orange
          red
          yellow
        ;

        bg = medium-bg;
        fg = light-bg;
        white = dark-fg;
      };

      keybinds = {
        unbind = [
          "Ctrl o"
          "Ctrl n"
        ];

        # shared_except = [
        #   {
        #     _args = [ "locked" ];
        #     bind = {
        #       _args = [ "Ctrl y" ];
        #       SwitchToMode = "Session";
        #     };
        #   }
        #   {
        #     _args = [ "locked" ];
        #     bind = {
        #       _args = [ "Ctrl Shift n" ];
        #       SwitchToMode = "Resize";
        #     };
        #   }
        # ];
      };
    };
  };
}
