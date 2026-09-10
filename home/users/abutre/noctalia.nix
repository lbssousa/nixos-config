# Noctalia configuration for the abutre user: compositor (Umbriel) and shell.
_:

{
  # ── Compositor: Umbriel ────────────────────────────────────────────────
  programs.umbriel = {
    enable = true;
    settings = {
      # Umbriel's general.autostart runs shell commands once after startup —
      # it does NOT process XDG autostart entries (that's why
      # programs.keepassxc.autostart is not used). "keepassxc" must launch with
      # the session so its org.freedesktop.secrets integration (enabled in
      # modules/home/apps/security/keepassxc.nix) is available to apps.
      general.autostart = [
        "noctalia"
        "keepassxc"
      ];

      # br+abnt2 layout for the session.
      # Mirrors services.xserver.xkb defined in localization.nix — already
      # propagated via XKB_DEFAULT_LAYOUT, set explicitly here for robustness.
      input.keyboard = {
        layout = "br";
        variant = "abnt2";
      };

      keybinds = {
        "Mod+Return" = "spawn:ghostty";
        "Mod+Shift+Q" = "window-close";
        # Opens Noctalia's app launcher (replaces the GNOME Shell overview).
        "Mod" = "spawn:noctalia msg panel-toggle launcher";
      };
    };
  };

  # ── Shell: Noctalia ────────────────────────────────────────────────────
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        # Noctalia's own polkit agent — no separate agent package needed.
        polkit_agent = true;
      };

      theme = {
        mode = "dark";
        source = "builtin";
        # Matches the Catppuccin Mocha palette used elsewhere (starship, greeter).
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
