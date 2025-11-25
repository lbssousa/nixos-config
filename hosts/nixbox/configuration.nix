# Configuration for nixbox (VirtualBox VM)
{ config, lib, pkgs, inputs, ... }:

{
  # System configuration
  networking.hostName = "nixbox";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # VirtualBox guest additions
  virtualisation.virtualbox.guest.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    xkb.layout = "br";
  };

  # Console keymap
  console.keyMap = "br-abnt2";

  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Internationalization
  i18n.defaultLocale = "pt_BR.UTF-8";

  # User account
  users.users.laercio = {
    isNormalUser = true;
    description = "Laércio de Sousa";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "vboxsf" ];
    initialPassword = "changeme"; # Change on first login
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    # Container tools
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  # Enable Flatpak
  services.flatpak.enable = true;

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

  # Impermanence configuration
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/systemd"
      "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.laercio = {
      directories = [
        "Downloads"
        "Documents"
        ".ssh"
        ".local/share/keyrings"
        ".mozilla"
        ".config/gh"
      ];
      files = [
        ".bash_history"
      ];
    };
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true; # VM can use password auth
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = false; # Enable after initial setup
    flake = "/etc/nixos#nixbox";
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
