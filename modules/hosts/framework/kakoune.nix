{ lib, pkgs }:

let
  plugins = with pkgs.kakounePlugins; [
    kak-lsp
  ];

  binPath = with pkgs; [
    gopls
    rnix-lsp
    clang-tools
    rust-analyzer
    python310Packages.python-lsp-server
    nodePackages.typescript-language-server
  ];

in (pkgs.kakoune.override {
  inherit plugins;
}).overrideAttrs (o: rec {
  buildCommand = (o.buildCommand or "") + ''
    wrapProgram $out/bin/kak \
      --prefix PATH ":" ${lib.makeBinPath binPath}
  '';
})
