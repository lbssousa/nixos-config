# Configuration for nixbox (VirtualBox VM)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/common.nix
    ../../modules/audio.nix
    ../../modules/containers.nix
    ../../modules/impermanence.nix
    ../../modules/packages.nix
    ../../modules/ssh.nix
    ../../modules/users.nix
  ];

  # System configuration
  networking.hostName = "nixbox";

  # VirtualBox guest additions
  virtualisation.virtualbox.guest.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Flatpak para VMs (precisa de XDG portal)
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Adicionar vboxsf ao grupo do usuário
  users.users.laercio.extraGroups = [ "vboxsf" ];

  # VM pode usar autenticação por senha
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

  # Desabilitar audio features não necessárias em VM
  services.pipewire.alsa.support32Bit = lib.mkForce false;
  services.pipewire.jack.enable = lib.mkForce false;

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Enable after initial setup
    flake = "/etc/nixos#nixbox";
  };
}
