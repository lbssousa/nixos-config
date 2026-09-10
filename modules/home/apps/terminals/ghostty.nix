# Ghostty configuration — the system's default terminal.
#
# Single usage profile: every Ghostty window opens undecorated
# (Umbriel/Noctalia draws no client-side titlebar), launched with a plain
# `ghostty` (e.g. Mod+Return in the Umbriel keybinds — no special classes,
# desktop entries or flags).
_:

{
  xdg.configFile."ghostty/config".text = ''
    # ── Font ───────────────────────────────────────────────────────────────
    font-family = JetBrainsMono Nerd Font
    font-size = 14

    # ── Appearance ─────────────────────────────────────────────────────────
    # No window decorations (Umbriel/Noctalia draws no client-side titlebar)
    window-decoration = false

    # Window opacity (90%)
    background-opacity = 0.90

    # GNOME palette (dark theme — matches Ptyxis's default)
    background = 171421
    foreground = D0CFCC
    palette = 0=#171421
    palette = 1=#C01C28
    palette = 2=#26A269
    palette = 3=#A2734C
    palette = 4=#12488B
    palette = 5=#A347BA
    palette = 6=#2AA1B3
    palette = 7=#D0CFCC
    palette = 8=#5E5C64
    palette = 9=#F66151
    palette = 10=#33D17A
    palette = 11=#E9AD0C
    palette = 12=#2A7BDE
    palette = 13=#C061CB
    palette = 14=#33C7DE
    palette = 15=#FFFFFF

    # Bold text uses the bright palette colors (indices 8–15)
    bold-color = bright

    # ── Behavior ───────────────────────────────────────────────────────────
    quit-after-last-window-closed = true
    confirm-close-surface = false
    bell-features = system

    # Disable auto-update (package managed by Nix)
    auto-update = off
  '';
}
