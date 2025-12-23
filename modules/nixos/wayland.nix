{ pkgs, ... }:
{
  # programs.hyprland = {
  #   enable = true;
  # };

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd niri-session
      '';
    };
  };

  environment.etc."greetd/environments".text = ''
    Niri
  '';
}
