# Módulo comum: Configurações básicas do sistema
{ config, lib, pkgs, ... }:

{
  # Allow unfree packages (needed for Nvidia drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Kernel parameters padrão
  boot.kernelParams = lib.mkDefault [
    "quiet"
    "splash"
  ];

  # Networking
  networking.networkmanager.enable = true;

  # Localização
  console.keyMap = "br-abnt2";
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";

  # X11 básico
  services.xserver = {
    enable = true;
    xkb.layout = "br";
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System state version
  system.stateVersion = "25.05";
}
