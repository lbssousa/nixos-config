# Configuração de disco para bigodon (Morefine M6)
# Mini-PC com 16 GB RAM - swap híbrida: 20 GB em disco (hibernação) + zram
import ../../disko.nix {
  device = "/dev/nvme0n1";  # Ajuste conforme necessário
  swapSize = "20G";  # Para suportar hibernação (16 GB RAM + margem)
}
