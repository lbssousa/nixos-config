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
  ];

  # System configuration
  networking.hostName = "barbudus";

  # Graphics configuration - hybrid Intel + Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
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
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Video drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  # Nvidia-specific package
  environment.systemPackages = with pkgs; [
    nvidia-offload # Helper script for PRIME offload
  ];

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Enable after initial setup
    flake = "/etc/nixos#barbudus";
  };
}
