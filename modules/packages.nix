# Módulo comum: Pacotes essenciais do sistema
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    pciutils
    usbutils
  ];
}
