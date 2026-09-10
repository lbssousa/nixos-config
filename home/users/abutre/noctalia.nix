# Noctalia configuration for the abutre user: compositor (Umbriel) and shell.
# Umbriel and Noctalia HM modules come from the upstream flakes
# (github:noctalia-dev/umbriel and github:noctalia-dev/noctalia), imported
# via home/mkUserHome.nix sharedModules. They provide programs.umbriel.settings
# and programs.noctalia.settings which serialize to TOML automatically.
#
# Keybinds follow Omarchy conventions where possible (Super = Mod):
#   https://omarchy.org/manual/hotkeys
{ ... }:

{
  # ── Compositor: Umbriel ────────────────────────────────────────────────
  programs.umbriel = {
    enable = true;
    settings = {
      general.autostart = [ "noctalia" "keepassxc" ];

      input.keyboard = {
        layout = "br";
        variant = "abnt2";
      };

      keybinds = {
        # ── App launchers (Omarchy: Super+Return = terminal) ──────────────
        "Mod+Return" = "spawn:ghostty";
        "Mod+Shift+Return" = "spawn:firefox";

        # ── Window management ────────────────────────────────────────────
        "Mod+W" = "window-close";
        "Mod+Q" = "window-close";
        "Mod+Shift+Q" = "window-close";
        "Mod+T" = "window-toggle-floating";
        "Mod+F" = "window-toggle-fullscreen";

        # ── Focus (Omarchy: Super+Arrow) ────────────────────────────────
        "Mod+Left" = "window-focus-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Up" = "window-focus-up";
        "Mod+Down" = "window-focus-down";

        # ── Swap (Omarchy: Super+Shift+Arrow) ───────────────────────────
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+Up" = "window-move-up";
        "Mod+Shift+Down" = "window-move-down";

        # ── Workspaces (Omarchy: Super+1/2/3/4) ────────────────────────
        "Mod+1" = "workspace-switch:1";
        "Mod+2" = "workspace-switch:2";
        "Mod+3" = "workspace-switch:3";
        "Mod+4" = "workspace-switch:4";
        "Mod+Tab" = "workspace-next";
        "Mod+Shift+Tab" = "workspace-previous";

        # ── Move window to workspace (Omarchy: Super+Shift+1/2/3/4) ────
        "Mod+Shift+1" = "window-move-to-workspace:1";
        "Mod+Shift+2" = "window-move-to-workspace:2";
        "Mod+Shift+3" = "window-move-to-workspace:3";
        "Mod+Shift+4" = "window-move-to-workspace:4";

        # ── Layout (Omarchy: Super+L = toggle layout) ───────────────────
        "Mod+L" = "workspace-set-layout:toggle";

        # ── Scratchpad (Omarchy: Super+S) ───────────────────────────────
        "Mod+S" = "scratchpad-toggle";
        "Mod+Shift+S" = "window-move-to-scratchpad";

        # ── Overview (Omarchy: Super+J overview) ────────────────────────
        "Mod+I" = "overview-toggle";

        # ── Monitor focus (Omarchy: Super+Alt+Arrows) ───────────────────
        "Mod+Alt+Left" = "output-focus-left";
        "Mod+Alt+Right" = "output-focus-right";
        "Mod+Alt+Up" = "output-focus-up";
        "Mod+Alt+Down" = "output-focus-down";

        # ── Resize windows (Omarchy: Super+Minus/Equal) ─────────────────
        "Mod+Minus" = "window-modify-width:-0.05";
        "Mod+Equal" = "window-modify-width:0.05";
        "Mod+Shift+Minus" = "window-modify-height:-0.05";
        "Mod+Shift+Equal" = "window-modify-height:0.05";

        # ── Workspace cycling (Omarchy: Super+ScrollWheel) ──────────────
        "Mod+WheelUp" = "window-focus-left";
        "Mod+WheelDown" = "window-focus-right";
        "Mod+Shift+WheelUp" = "column-move-left";
        "Mod+Shift+WheelDown" = "column-move-right";

        # ── Noctalia shell integration ──────────────────────────────────
        "Mod" = "spawn:noctalia msg panel-toggle launcher";
        "Mod+Escape" = "spawn:noctalia msg panel-toggle session";
        "Mod+V" = "spawn:noctalia msg panel-toggle clipboard";

        # ── Screenshots (Omarchy: Print Screen) ─────────────────────────
        "Print" = "spawn:noctalia msg screenshot-fullscreen";
        "Alt+Print" = "spawn:noctalia msg screenshot-region";
        "Mod+Print" = "spawn:noctalia msg color-picker";

        # ── Lock (Omarchy: Super+Ctrl+L) ────────────────────────────────
        "Mod+Ctrl+L" = "spawn:loginctl lock-session";

        # ── Media keys ──────────────────────────────────────────────────
        "XF86AudioPlay" = "spawn:playerctl play-pause";
        "XF86AudioNext" = "spawn:playerctl next";
        "XF86AudioPrev" = "spawn:playerctl previous";
        "XF86AudioRaiseVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "Mod+XF86AudioMute" = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        # ── Brightness ──────────────────────────────────────────────────
        "XF86MonBrightnessUp" = "spawn:brightnessctl set +5%";
        "XF86MonBrightnessDown" = "spawn:brightnessctl set 5%-";
      };
    };
  };

  # ── Shell: Noctalia ────────────────────────────────────────────────────
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        polkit_agent = true;
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      dock = {
        enabled = true;
        pinned = [
          "org.mozilla.firefox"
          "com.brave.Browser"
          "code"
          "dev.zed.Zed"
        ];
      };
    };
  };
}
