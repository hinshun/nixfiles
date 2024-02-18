{ palettes, ... }:
{
  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    settings = [{
      layer = "top";
      position = "bottom";
      height = 20;
      modules-left = [
        "cpu"
        "memory"
      ];
      modules-center = [
        "hyprland/workspaces"
      ];
      modules-right = [
        "backlight"
        "pulseaudio"
        "battery"
        "clock"
        "tray"
      ];

      "hyprland/workspaces" = {
        "on-click" = "activate";
        "all-outputs" = true;
      };

      "tray" = {
        "icon-size" = 18;
        "spacing" = 5;
        "show-passive-items" = true;
      };

      "clock" = {
        "format" = "{:%I:%M %p}";
        "format-alt" = "{:%R 󰃭 %d·%m·%y}";
        "tooltip-format" = "<tt>{calendar}</tt>";
        "calendar" = {
          "mode" = "month";
          "mode-mon-col" = 3;
          "on-scroll" = 1;
          "on-click-right" = "mode";
          "format" = {
            "months" = "<span color='#ffead3'><b>{}</b></span>";
            "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
            "today" = "<span color='#ff6699'><b>{}</b></span>";
          };
        };
        "actions" = {
          "on-click-right" = "mode";
          "on-click-forward" = "tz_up";
          "on-click-backward" = "tz_down";
          "on-scroll-up" = "shift_up";
          "on-scroll-down" = "shift_down";
        };
      };

      "cpu" = {
          "interval" = 2;
          "format" = "{usage}% ";
          "tooltip" = false;
      };

      "memory" = {
          "interval" = 15;
          "format" = "{}% ";
      };

      "backlight" = {
          "format" = "{percent}% {icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" ""];
      };

      "battery" = {
          "states" = {
              "warning" = 30;
              "critical" = 15;
          };
          "format" = "{capacity}% {icon} ";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-alt" = "{time} {icon}";
          "format-icons" = ["" "" "" "" ""];
      };

      "network" = {
          "format-wifi" = " :{ipaddr}";
          "format-ethernet" = " :{ipaddr}/{cidr}";
          "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
          "tooltip-format" = "{ifname} via {gwaddr}";
          "format-linked" = "{ifname} (No IP)";
          "format-disconnected" = "Disconnected";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
      };

      "pulseaudio" = {
          "format" = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon} 󰂯";
          "format-bluetooth-muted" = "󰖁 {icon} 󰂯";
          "format-muted" = "󰖁 {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "󱡒";
              "headset" = "󰋎";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = ["" "" ""];
          };
          "on-click" = "pavucontrol";
      };

      "custom/power" = {
        "format" = "{icon}";
        "format-icons" = "";
        "exec-on-event" = "true";
        "on-click" = "wlogout";
      };
    }];

    style = with palettes.toffee; ''
      * {
        border: none;
        border-radius: 0px;
        font-family: "FiraCode";
        font-weight: bold;
        font-size: 11px;
        min-height: 10px;
      }

      window#waybar {
        background: rgba(0, 0, 0, 0);
      }

      tooltip {
        background: rgba(0, 0, 0, 0);
        color: ${light-fg};
        border-radius: 7px;
        border-width: 0px;
      }

      #workspaces button {
        box-shadow: none;
        text-shadow: none;
        padding: 0px;
        border-radius: 9px;
        margin-top: 3px;
        margin-bottom: 3px;
        padding-left: 3px;
        padding-right: 3px;
        color: ${light-fg};
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #workspaces button.active {
        background: rgba(0, 0, 0, 0);
        color: ${white};
        margin-left: 3px;
        padding-left: 12px;
        padding-right: 12px;
        margin-right: 3px;
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0);
        color: ${white};
        padding-left: 3px;
        padding-right: 3px;
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #taskbar button {
        box-shadow: none;
        text-shadow: none;
        padding: 0px;
        border-radius: 9px;
        margin-top: 3px;
        margin-bottom: 3px;
        padding-left: 3px;
        padding-right: 3px;
        color: ${light-fg};
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #taskbar button.active {
        background: rgba(0, 0, 0, 0);
        color: ${light-fg};
        margin-left: 3px;
        padding-left: 12px;
        padding-right: 12px;
        margin-right: 3px;
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #taskbar button:hover {
        background: rgba(0, 0, 0, 0);
        color: ${white};
        padding-left: 3px;
        padding-right: 3px;
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #backlight,
      #battery,
      #bluetooth,
      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #taskbar,
      #tray,
      #window,
      #workspaces {
        color: ${light-fg};
        background: rgba(0, 0, 0, 0);
        opacity: 1;
        margin: 4px 0px 4px 0px;
        padding-left: 4px;
        padding-right: 4px;
      }

      #workspaces,
      #taskbar {
        padding: 0px;
      }
    '';
  };
}
