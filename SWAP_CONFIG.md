# Configuração de Swap Híbrida

Este repositório implementa uma estratégia de swap híbrida otimizada para diferentes tipos de hosts.

## Estratégia por Host

### 🖥️ barbudus (Dell Inspiron 14 5490) e bigodon (Morefine M6)
**Laptops/Mini-PC com 16 GB RAM**

**Configuração:**
- ✅ **Swap em disco**: 20 GB (LUKS criptografado, dentro do LVM)
  - Objetivo: Suportar hibernação (suspend-to-disk)
  - Prioridade: 5 (backup)
  
- ✅ **zram**: 8 GB (50% da RAM)
  - Objetivo: Performance no dia a dia
  - Compressão: zstd (ratio típico 2:1 a 3:1 = ~12-16 GB efetivos)
  - Prioridade: 100 (primária)

**Comportamento:**
1. Sistema usa zram primeiro (mais rápido, não desgasta SSD)
2. Quando zram enche, usa swap em disco
3. Hibernação funciona normalmente usando swap em disco

**Arquivos de configuração:**
- `hosts/barbudus/disko.nix` - Particionamento com swap 20GB
- `hosts/barbudus/hardware-configuration.nix` - Hardware + configuração zram
- `hosts/bigodon/disko.nix` - Particionamento com swap 20GB
- `hosts/bigodon/hardware-configuration.nix` - Hardware + configuração zram

### 🖧 nixbox (VirtualBox VM)
**Máquina Virtual**

**Configuração:**
- ❌ **Sem swap em disco** (VMs raramente hibernam)
- ✅ **zram**: 16 GB (100% da RAM)
  - Compressão: zstd (ratio típico 2:1 a 3:1 = ~24-32 GB efetivos)
  - Prioridade: 100 (única fonte)

**Vantagens para VMs:**
- Economiza espaço em disco virtual
- Melhor performance (RAM comprimida vs I/O virtualizado)
- Sem desgaste desnecessário do disco host

**Arquivos de configuração:**
- `hosts/nixbox/disko.nix` - Particionamento sem swap
- `hosts/nixbox/hardware-configuration.nix` - Hardware + configuração zram

## Como Usar

### Para novos hosts

1. Crie o diretório do host: `hosts/seu-host/`
2. Crie `disko.nix` importando o template base:
   ```nix
   import ../../disko.nix {
     device = "/dev/sda";  # Seu disco
     swapSize = "20G";     # "0" para desabilitar
   }
   ```
3. Em `hardware-configuration.nix`, adicione:
   - Import do disko: `(import ./disko.nix { inherit lib; })`
   - Configuração zram apropriada (veja exemplos nos outros hosts)
4. Importe o `hardware-configuration.nix` na configuração principal do host

### Ajustes recomendados

#### Para sistemas com mais/menos RAM:
- **8 GB RAM**: swap disco 12 GB, zram 50% (4 GB)
- **32 GB RAM**: swap disco 32 GB, zram 25% (8 GB)
- **64 GB+ RAM**: considerar apenas zram

#### Para workloads específicos:
- **Desenvolvimento leve**: Reduzir ou remover swap em disco
- **Compilações pesadas**: Aumentar zram para 75-100%
- **Edição de vídeo/ML**: Manter swap disco generoso

## Parâmetros Ajustáveis

### vm.swappiness
- **10** (barbudus/bigodon): Prefere manter processos em RAM, usa swap só quando necessário
- **60** (nixbox): Valor padrão, mais agressivo no uso de swap

### vm.vfs_cache_pressure
- **50** (laptops): Mantém mais cache de arquivos em memória
- **100** (VMs): Comportamento padrão balanceado

## Benefícios da Abordagem Híbrida

### ✅ Performance
- zram oferece 10-50x mais velocidade que swap em disco
- Reduz latência do sistema sob pressão de memória
- Não bloqueia I/O do disco

### ✅ Vida útil do SSD
- Reduz drasticamente escritas em disco
- zram opera totalmente em RAM

### ✅ Funcionalidade
- Hibernação funciona normalmente nos laptops
- Fallback seguro se zram não for suficiente

### ✅ Flexibilidade
- VMs podem usar apenas zram
- Laptops mantém hibernação funcional
- Fácil ajustar per-host

## Monitoramento

```bash
# Ver uso de swap
swapon --show

# Estatísticas de zram
zramctl

# Memória e swap em tempo real
watch -n 1 free -h

# Verificar compressão zram
cat /sys/block/zram0/mm_stat
```

## Referências

- [Kernel.org - zram](https://www.kernel.org/doc/html/latest/admin-guide/blockdev/zram.html)
- [NixOS Wiki - zramSwap](https://nixos.wiki/wiki/Zram)
- [Red Hat - Swap Space](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/getting-started-with-swap_managing-storage-devices)
