# Hardware configuration for barbudus (Dell Inspiron 14 5490)
# This file should be generated with: nixos-generate-config --show-hardware-config
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # Disko configuration
    (import ./disko.nix { inherit lib; })
  ];

  # CPU
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Enable microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Filesystems are configured via disko.nix
  fileSystems = lib.mkForce { };
  swapDevices = lib.mkForce [ ];

  # Swap híbrida: 20 GB em disco (hibernação) + 8 GB zram (performance)
  zramSwap = {
    enable = true;
    # 8 GB de zram (50% da RAM física)
    # Com compressão 2:1 a 3:1, oferece ~12-16 GB efetivos
    memoryPercent = 50;
    # Usar algoritmo zstd (melhor balanço performance/compressão)
    algorithm = "zstd";
    # Prioridade maior que swap em disco (será usada primeiro)
    priority = 100;
  };

  # Otimizações para swap híbrida
  boot.kernel.sysctl = {
    # Tendência menor de usar swap (boa para laptops)
    "vm.swappiness" = 10;
    # Manter páginas em cache para melhor responsividade
    "vm.vfs_cache_pressure" = 50;
  };

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
}
