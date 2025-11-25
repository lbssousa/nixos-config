# Configuração de swap para nixbox (VM)
# - Sem swap em disco
# - zram: 16 GB (100% da RAM física) como única fonte de swap
{ config, lib, pkgs, ... }:

{
  # Habilitar zramswap
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
  
  # Sem swap em disco para VMs
  swapDevices = lib.mkForce [];
  
  # Otimizações para zram apenas
  boot.kernel.sysctl = {
    # Tendência moderada de usar swap (VMs podem precisar mais)
    "vm.swappiness" = 60;
    
    # Balanço padrão para cache
    "vm.vfs_cache_pressure" = 100;
  };
}
