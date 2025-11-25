# Módulo para desktops físicos (não VMs)
{ config, lib, pkgs, ... }:

{
  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Printing
  services.printing.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Adicionar bluetooth às pastas persistentes
  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
  ];

  # Adicionar pastas de mídia para usuários de desktop
  environment.persistence."/persist".users.laercio.directories = [
    "Pictures"
    "Videos"
    "Music"
  ];
}
