{ ... }: {
  programs.firefox = {
    enable = true;
    profiles.hinshun = {
      settings = {
        "dom.security.https_only_mode" = true;
      };
    };
  };
}
