{ pkgs, ... }:
{
  home.sessionVariables = {
	  GTK_USE_PORTAL = "1";
	  NIXOS_OZONE_WL = "1";
	  MOZ_ENABLE_WAYLAND = "1";
	  NIXOS_XDG_OPEN_USE_PORTAL = "1";
	  WLR_RENDERER = "vulkan";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
	  XDG_SESSION_TYPE = "wayland";
	  XDG_CURRENT_DESKTOP = "Hyprland";
	  XDG_SESSION_DESKTOP = "Hyprland";
	};

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = with pkgs.hyprlandPlugins; [
      # Overview plugin toggled by SUPER+`
      hyprexpo
    ];

    extraConfig = ''
      bind = SUPER, R, submap, resize
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10
      bind = , escape, submap, reset
      submap = reset
    '';

    settings = {
      general = {
        layout = "dwindle";
        resize_on_border = true;

        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
      };

      input = {
        kb_options = "ctrl:nocaps";
      };

      misc = {
        force_default_wallpaper = 0;
      };

      dwindle = {
        # Enable pseudotiling; allow window size to be resized dynamically.
        pseudotile = "yes";
        # Split will not change regardless of what happens to container.
        preserve_split = "yes";
      };

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        # TODO: Causes a white floating window, get rid of it.
        # "${pkgs.xwaylandvideobridge}/bin/xwaylandvideobridge"
      ];

      plugin.hyprexpo = {
        # Enable laptop touchpad gestures, four finger swipe to toggle.
        enable_gesture = true;
      };

      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, return, exec, alacritty"
        "$mainMod SHIFT, Q, killactive"
        "$mainMod, D, exec, tofi-drun | xargs hyprctl dispatch exec --"
        "$mainMod, F, fullscreen"
        "$mainMod, grave, hyprexpo:expo, toggle"

        # Switch window: $mainMod + hjkl
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        # Move window in direction: $mainMod + SHIFT + hjkl
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, j, movewindow, d"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, l, movewindow, r"

        # Move workspace to monitor: $mainMod + ALT + hjkl
        "$mainMod ALT, h, movecurrentworkspacetomonitor, l"
        "$mainMod ALT, l, movecurrentworkspacetomonitor, r"

        # Switch workspaces: $mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace: $mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];

      bindm = [
        # Move/resize windows with mouse: $mainMod + LMB/RMB & drag
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
