{ config, lib, pkgs, ... }:

{
  # Terminal emulator
  environment.systemPackages = with pkgs; [
    # Ghostty - GPU-accelerated terminal
    ghostty
    
    # Network management tools
    networkmanagerapplet  # Applet gráfico do NetworkManager
    
    # QuickShell dependencies
    qt6.full
    qt6.qtwayland
    
    # Utilitários Wayland
    wtype  # Simular input de teclado
    wlr-randr  # Gerenciar outputs
    kanshi  # Gerenciar configurações de monitor automaticamente
    
    # File manager
    xfce.thunar
    xfce.thunar-volman
    gvfs  # Suporte a montagem de volumes
    
    # Image viewer
    imv
    
    # PDF viewer
    zathura
    
    # Screenshots e screencasts
    grimblast  # wrapper para grim + slurp
    wf-recorder  # Screen recording
    
    # Clipboard manager
    cliphist
    
    # Color picker
    hyprpicker
  ];

  # Thunar e serviços relacionados
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # GVFS para montagem automática
  services.gvfs.enable = true;

  # Tumbler para thumbnails no Thunar
  services.tumbler.enable = true;
}
