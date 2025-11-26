# Configuration for bigodon (Morefine M6)
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
  networking.hostName = "bigodon";

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Video drivers (Intel)
  services.xserver.videoDrivers = [ "modesetting" ];

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Enable after initial setup
    flake = "/etc/nixos#bigodon";
  };
}
