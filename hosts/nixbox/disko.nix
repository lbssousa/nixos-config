# Configuração de disco para nixbox (VirtualBox VM)
# VM - sem swap em disco, apenas zramswap
import ../../disko.nix {
  device = "/dev/sda";  # Disco virtual VirtualBox
  swapSize = "0";  # VM não precisa de hibernação
}
