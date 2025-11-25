# Módulo comum: Usuário padrão
{ config, lib, pkgs, ... }:

{
  users.users.laercio = {
    isNormalUser = true;
    description = "Laércio de Sousa";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    initialPassword = "changeme"; # Change on first login
  };
}
