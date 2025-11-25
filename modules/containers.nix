# Módulo comum: Containers (Podman + Distrobox)
{ config, lib, pkgs, ... }:

{
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;

  # Enable Podman for rootless containers (required for Distrobox)
  virtualisation.podman = {
    enable = true;
    # Create a `docker` alias for podman
    dockerCompat = true;
    # Required for containers under podman-compose to be able to talk to each other
    defaultNetwork.settings.dns_enabled = true;
    # Enable support for rootless containers
    # Podman will use user namespaces to run containers without root privileges
  };

  # Container management tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];
}
