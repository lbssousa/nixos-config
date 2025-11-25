# Hardware configuration for nixbox (VirtualBox VM)
# This file should be generated with: nixos-generate-config --show-hardware-config
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    # Disko configuration
    (import ./disko.nix { inherit lib; })
  ];

  # CPU
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Filesystems are configured via disko.nix
  fileSystems = lib.mkForce { };
  swapDevices = lib.mkForce [ ];

  # Swap apenas zram: 16 GB (100% da RAM) como única fonte
  zramSwap = {
    enable = true;
    # 16 GB de zram (100% da RAM física)
    # Com compressão 2:1 a 3:1, oferece ~24-32 GB efetivos
    memoryPercent = 100;
    # Usar algoritmo zstd (melhor balanço performance/compressão)
    algorithm = "zstd";
    # Prioridade padrão (única fonte de swap)
    priority = 100;
  };

  # Otimizações para zram apenas
  boot.kernel.sysctl = {
    # Tendência moderada de usar swap (VMs podem precisar mais)
    "vm.swappiness" = 60;
    # Balanço padrão para cache
    "vm.vfs_cache_pressure" = 100;
  };

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}
