# Configuration for barbudus (Dell Inspiron 14 5490)
{ config, lib, pkgs, inputs, ... }:

{
  # System configuration
  networking.hostName = "barbudus";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Kernel parameters for hybrid graphics (Intel + Nvidia)
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

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

  # Networking
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    initialPassword = "changeme"; # Change on first login
  };

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

  # Additional packages for container management
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    pciutils
    usbutils
    nvidia-offload # Helper script for PRIME offload
    # Container tools
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  # Impermanence configuration
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
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
        "Pictures"
        "Videos"
        "Music"
        ".ssh"
        ".gnupg"
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
    settings.PasswordAuthentication = false;
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
    flake = "/etc/nixos#barbudus";
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
