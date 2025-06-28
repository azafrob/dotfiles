{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      monitor = [
        "DP-1,3440x1440@120,0x0,1"
	"HDMI-A-1,disable"
	"SUNSHINE,1280x800@360,0x0,1,bitdepth,10"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &"
        "(dunst & hyprpaper & waybar &)"
      ];

      env = [
      ];

      "$terminal" = "ghostty";
      "$menu" = "wofi --show drun";
      "$fileManager" = "yazi";
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;
        sensitivity = 0.2;
      };

      general = {
        gaps_in = 10;
        gaps_out = 10;
        border_size = 1;
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 0;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        enable_swallow = true;
        force_default_wallpaper = -1;
      };

      windowrulev2 = "suppressevent maximize, class:.*";

      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Space, exec, $menu"
        "$mainMod, Q, killactive"
        "$mainMod, C, exit"
	"CTRL SHIFT, X, exec, LD_AUDIT='/home/vee/Downloads/SLSsteam/bin/SLSsteam.so' steam steam://open/bigpicture"
        "$mainMod, TAB, workspace, previous"
        "$mainMod, G, exec, pkill waybar || waybar"
        "$mainMod, E, exec, $fileManager"
        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"
        "$mainMod, V, togglefloating"
        "$mainMod, N, exec, navi"
        "$mainMod, P, pseudo"
        "$mainMod, D, togglesplit"
        "$mainMod, NEXT, exec, hyprshot -m output"
        "$mainMod SHIFT, NEXT, exec, hyprshot -m region"
        ", XF86AudioRaiseVolume, exec, pamixer -i 2"
        ", XF86AudioLowerVolume, exec, pamixer -d 2"
        ", XF86AudioMute, exec, pamixer -t"
        ", SHIFT_XF86AudioRaiseVolume, exec, pamixer --default-source --increase 2"
        ", SHIFT_XF86AudioLowerVolume, exec, pamixer --default-source --decrease 2"
        ", SHIFT_XF86AudioMute, exec, pamixer --default-source -t"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
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
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
