# Base graphical environment module — shared by all desktops.
# Noctalia-specific configuration lives in dendritic/flake/noctalia-wrapper.nix.
{ pkgs, ... }:
{
  programs = {
    # Enables running unpatched FHS binaries (e.g. dev tools distributed as
    # generic Linux binaries). Without nix-ld, they fail with "stub-ld" errors.
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # libstdc++.so.6
        zlib
        alsa-lib # libasound.so.2
        wayland # libwayland-client.so.0

        # Electron/GTK runtime libraries needed by Homebrew casks (e.g.
        # visual-studio-code-linux) that ship prebuilt Linux binaries.
        nspr
        nss
        glib
        gtk3
        cairo
        pango
        gdk-pixbuf
        atk
        at-spi2-atk
        at-spi2-core
        dbus
        expat
        fontconfig
        freetype
        cups
        mesa
        libdrm
        libxkbcommon
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxshmfence
      ];
    };
  };

  # XDG Portal for Nix and Flatpak apps (file chooser fallback for GTK apps).
  # Umbriel's NixOS module (programs.umbriel) contributes its own portal
  # backend on top of this — see dendritic/flake/noctalia-wrapper.nix.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Essential desktop fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.adwaita-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.hack
      nerd-fonts.inconsolata
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.ubuntu-mono
      nerd-fonts.zed-mono
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Graphical editor with an FHS environment: lets extensions and helper
  # tools that depend on standard FHS paths work correctly on NixOS.
  # Note: VS Code itself is no longer installed here — it comes from the
  # Homebrew "visual-studio-code-linux" cask (system-level config in
  # modules/system/tools/homebrew.nix), which is genuinely FHS-compliant and
  # needs no wrapper.
  environment.systemPackages = with pkgs; [
    zed-editor-fhs
  ];

  # Electron: force automatic Wayland detection in all Nix apps.
  environment.variables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  # /var/lib/dbus/machine-id is ephemeral (/ is tmpfs). Apps that use
  # libdbus (not dbus-broker) — like epson-printer-utility — read this path.
  # The rule below recreates the symlink on every boot.
  systemd.tmpfiles.rules = [
    "d  /var/lib/dbus             0755 root root - -"
    "L+ /var/lib/dbus/machine-id  -    -    -    - /etc/machine-id"
  ];
}
