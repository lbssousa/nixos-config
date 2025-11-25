# Módulo comum: Usuário padrão
{ config, lib, pkgs, ... }:

{
  # Habilitar ZSH globalmente
  programs.zsh.enable = true;

  users.users.laercio = {
    isNormalUser = true;
    description = "Laércio de Sousa";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    initialPassword = "changeme"; # Change on first login
    shell = pkgs.zsh;
  };
}
