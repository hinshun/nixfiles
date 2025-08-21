{ pkgs, palettes, ... }:
{
  programs.helix = {
    enable = true;

    defaultEditor = true;

    settings = {
      theme = "hinshun";
      editor.lsp = {
        display-inlay-hints = true;
      };

    };

    languages = {
      language = [
        # {
        #   name = "nix";
        #   language-servers = [ "nixd" ];
        # }
      ];

      language-server = {
        # nixd.command = "nixd";
      };

      language-server = {
        rust-analyzer.config = {
          inlayHints = {
            bindingModeHints.enable = false;
            closingBraceHints.minLines = 10;
            closureReturnTypeHints.enable = "with_block";
            discriminantHints.enable = "fieldless";
            lifetimeElisionHints.enable = "skip_trivial";
            typeHints.hideClosureInitialization = false;
          };
        };
      };
    };

    themes = {
      hinshun = {
        "attribute" = { fg = "yellow"; };
        "comment" = { fg = "dark-fg"; modifiers = ["italic"]; };
        "constant" = { fg = "orange"; };
        "constant.numeric" = { fg = "red"; };
        "constant.builtin" = { fg = "orange"; };
        "constant.builtin.boolean" = { fg = "orange"; };
        "constant.character.escape" = { fg = "yellow"; };
        "constructor" = { fg = "yellow"; };
        "function" = { fg = "yellow"; };
        "function.builtin" = { fg = "yellow"; };
        "function.macro" = { fg = "magenta"; };
        "keyword" = { fg = "purple"; };
        "keyword.control" = { fg = "purple"; };
        "keyword.control.import" = { fg = "purple"; };
        "keyword.directive" = { fg = "purple"; };
        "label" = { fg = "blue"; };
        "namespace" = { fg = "blue"; };
        "operator" = { fg = "light-blue"; };
        "keyword.operator" = { fg = "purple"; };
        "special" = { fg = "yellow"; };
        "string" = { fg = "green"; };
        "type" = { fg = "cyan"; };
        "variable" = { fg = "light-fg"; };
        "variable.builtin" = { fg = "magenta"; };
        "variable.parameter" = { fg = "yellow"; };
        "variable.other.member" = { fg = "light-fg"; };

        "markup.heading" = { fg = "red"; };
        "markup.raw.inline" = { fg = "green"; };
        "markup.bold" = { fg = "yellow"; modifiers = ["bold"]; };
        "markup.italic" = { fg = "purple"; modifiers = ["italic"]; };
        "markup.strikethrough" = { modifiers = ["crossed_out"]; };
        "markup.list" = { fg = "red"; };
        "markup.quote" = { fg = "yellow"; };
        "markup.link.url" = { fg = "cyan"; modifiers = ["underlined"]; };
        "markup.link.text" = { fg = "purple"; };

        "diff.plus" = "green";
        "diff.delta" = "yellow";
        "diff.minus" = "red";

        "diagnostic.info".underline = { color = "blue"; style = "curl"; };
        "diagnostic.hint".underline = { color = "green"; style = "curl"; };
        "diagnostic.warning".underline = { color = "yellow"; style = "curl"; };
        "diagnostic.error".underline = { color = "red"; style = "curl"; };
        "info" = { fg = "blue"; modifiers = ["bold"]; };
        "hint" = { fg = "green"; modifiers = ["bold"]; };
        "warning" = { fg = "yellow"; modifiers = ["bold"]; };
        "error" = { fg = "red"; modifiers = ["bold"]; };

        "ui.background" = { bg = "dark-bg"; };
        "ui.virtual" = { fg = "medium-bg"; };
        "ui.virtual.indent-guide" = { fg = "medium-bg"; };
        "ui.virtual.whitespace" = { fg = "dark-fg"; };
        "ui.virtual.ruler" = { bg = "medium-bg"; };
        "ui.virtual.inlay-hint" = { fg = "light-bg"; };
        "ui.virtual.jump-label" = { fg = "red"; };

        "ui.cursor" = { fg = "white"; modifiers = ["reversed"]; };
        "ui.cursor.primary" = { fg = "white"; modifiers = ["reversed"]; };
        "ui.cursor.match" = { fg = "blue"; modifiers = ["underlined"]; };

        "ui.selection" = { bg = "medium-bg"; };
        "ui.selection.primary" = { bg = "medium-bg"; };
        "ui.cursorline.primary" = { bg = "medium-bg"; };

        "ui.highlight" = { bg = "medium-bg"; };
        "ui.highlight.frameline" = { bg = "#97202a"; };

        "ui.linenr" = { fg = "medium-bg"; };
        "ui.linenr.selected" = { fg = "light-fg"; };

        "ui.statusline" = { fg = "white"; bg = "dark-bg"; };
        "ui.statusline.inactive" = { fg = "dark-fg"; bg = "medium-bg"; };
        "ui.statusline.normal" = { fg = "medium-bg"; bg = "blue"; };
        "ui.statusline.insert" = { fg = "medium-bg"; bg = "green"; };
        "ui.statusline.select" = { fg = "medium-bg"; bg = "purple"; };

        "ui.text" = { fg = "light-fg"; };
        "ui.text.focus" = { fg = "white"; bg = "medium-bg"; modifiers = ["bold"]; };

        "ui.help" = { fg = "white"; bg = "medium-bg"; };
        "ui.popup" = { bg = "medium-bg"; };
        "ui.window" = { fg = "medium-bg"; };
        "ui.menu" = { fg = "light-fg"; bg = "medium-bg"; };
        "ui.menu.selected" = { fg = "dark-bg"; bg = "blue"; };
        "ui.menu.scroll" = { fg = "light-fg"; bg = "dark-fg"; };

        "ui.debug" = { fg = "red"; };


        palette = with palettes.toffee; {
          inherit
            black
            blue
            cyan
            dark-bg
            dark-fg
            green
            light-bg
            light-blue
            light-fg
            magenta
            medium-bg
            orange
            purple
            red
            white
            yellow
          ;
        };
      };
    };
  };

  home.packages = with pkgs; [
    gopls
    nil
    # nixd
    python3Packages.python-lsp-server
    rust-analyzer
  ];
}
