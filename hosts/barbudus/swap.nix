# Configuração de swap híbrida para barbudus
# - Swap em disco: 20 GB (para hibernação)
# - zram: 8 GB (para performance no dia a dia)
{ config, lib, pkgs, ... }:

{
  # Habilitar zramswap
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
  
  # Swap em disco tem prioridade menor (configurada via disko.nix)
  # Será usada apenas quando zram estiver cheia
  swapDevices = lib.mkForce [];  # Configurado via disko.nix
  
  # Otimizações para swap híbrida
  boot.kernel.sysctl = {
    # Tendência menor de usar swap (boa para laptops)
    "vm.swappiness" = 10;
    
    # Manter páginas em cache para melhor responsividade
    "vm.vfs_cache_pressure" = 50;
  };
}
