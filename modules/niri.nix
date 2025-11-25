{ config, lib, pkgs, ... }:

{
  # Niri compositor Wayland
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # XDG Desktop Portal para integração Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome  # Portal GNOME para file picker, screenshots
    ];
    config.common.default = "*";
  };

  # Polkit para elevação de privilégios
  security.polkit.enable = true;

  # Agent gráfico do polkit
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Autologin na tty1 para o usuário laercio
  services.getty.autologinUser = "laercio";

  # Variáveis de ambiente para Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Electron apps usarem Wayland
    MOZ_ENABLE_WAYLAND = "1";  # Firefox Wayland
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  # Pacotes essenciais para Niri
  environment.systemPackages = with pkgs; [
    # Compositor e ferramentas
    niri
    wayland
    wayland-protocols
    wayland-utils
    
    # Ferramentas de screenshot/screen recording
    grim
    slurp
    wl-clipboard
    
    # Notificações
    mako
    libnotify
    
    # Launcher de aplicações
    fuzzel
    
    # Bar/status
    waybar
    
    # Polkit
    polkit_gnome
    
    # Autenticação
    gnome.seahorse
  ];

  # Fontes necessárias
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
