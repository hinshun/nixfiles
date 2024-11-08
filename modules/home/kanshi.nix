{
  # Wayland daemon that automatically configures outputs.
  services.kanshi = {
    enable = true;

    # Default target is sway, but we're using hyprland.
    # See: https://haseebmajid.dev/posts/2023-07-25-nixos-kanshi-and-hyprland/
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "home-office";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. Dell AW3420DW 4ZTHTY2";
            position = "0,0";
            mode = "3440x1440@49.99Hz";
          }
        ];
      }
    ];
  };
}
