# Configuração de disco para nixbox (VirtualBox VM)
# VM - sem swap em disco, apenas zramswap
{ lib, ... }:

import ../../disko.nix {
  inherit lib;
  device = "/dev/sda";  # Disco virtual VirtualBox
  swapSize = "0";  # VM não precisa de hibernação
}
