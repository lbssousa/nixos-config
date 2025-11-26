# Configuration for barbudus (Dell Inspiron 14 5490)
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
    ../../modules/desktop.nix
    ../../modules/niri.nix
    ../../modules/wayland-apps.nix
  ];

  # System configuration
  networking.hostName = "barbudus";

  # Graphics configuration - hybrid Intel + Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;  # Use proprietary driver for MX230 (older GPU)
    prime = {
      # Find bus IDs with: lspci | grep VGA
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      
      # Use PRIME offloading for better battery life
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Video drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Enable after initial setup
    flake = "/etc/nixos#barbudus";
  };
}
