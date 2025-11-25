# Estrutura de Subvolumes Btrfs

Este repositório implementa uma estratégia de subvolumes Btrfs otimizada para NixOS com impermanence, Flatpak e Podman.

## 📁 Estrutura de Subvolumes

### **@ (raiz ephemeral)**
- **Mountpoint**: `/`
- **Características**: Limpo a cada boot (impermanence)
- **Compressão**: zstd
- **Uso**: Sistema operacional base, arquivos temporários

### **@home (diretórios de usuário)**
- **Mountpoint**: `/home`
- **Características**: Preservado entre boots
- **Compressão**: zstd
- **Uso**: Arquivos pessoais, configurações de usuário

### **@nix (Nix store)**
- **Mountpoint**: `/nix`
- **Características**: Preservado entre boots (essencial)
- **Compressão**: zstd
- **Uso**: Pacotes Nix, derivações, profiles

### **@persist (dados persistentes do sistema)**
- **Mountpoint**: `/persist`
- **Características**: Preservado entre boots
- **Compressão**: zstd
- **Uso**: Configurações de sistema, segredos, dados críticos
- **Nota**: Usado pelo módulo impermanence para preservar arquivos específicos

### **@log (logs do sistema)**
- **Mountpoint**: `/var/log`
- **Características**: Preservado entre boots
- **Compressão**: Desabilitada (nocomp)
- **Uso**: Logs de sistema e aplicações
- **Nota**: Logs já são comprimidos, compressão adicional seria redundante

### **@containers (containers)**
- **Mountpoint**: `/var/lib/containers`
- **Características**: Preservado entre boots
- **Compressão**: zstd
- **Uso**: Imagens, volumes e dados de containers (Podman, Docker, etc.)
- **Benefícios**: 
  - Isolamento de dados de containers (Podman, Docker, etc.)
  - Snapshots independentes
  - Fácil backup/restauração
  - Compatível com múltiplos runtimes de containers

### **@flatpak (aplicações Flatpak)**
- **Mountpoint**: `/var/lib/flatpak`
- **Características**: Preservado entre boots
- **Compressão**: zstd
- **Uso**: Aplicações Flatpak instaladas no sistema
- **Benefícios**:
  - Isolamento de aplicações Flatpak
  - Snapshots independentes
  - Fácil backup/restauração

### **@snapshots (backups)**
- **Mountpoint**: `/.snapshots`
- **Características**: Preservado entre boots
- **Compressão**: zstd
- **Uso**: Armazenamento de snapshots Btrfs
- **Nota**: Preparado para ferramentas como snapper ou timeshift

## 🎯 Estratégia de Impermanence

Com esta configuração:

1. **Sistema limpo a cada boot**: O subvolume `@` é limpo, garantindo um sistema sempre em estado conhecido
2. **Dados preservados seletivamente**: Apenas o que está em `/persist`, `/home`, `/nix` e outros subvolumes específicos é mantido
3. **Isolamento de aplicações**: Flatpak e Podman têm seus próprios subvolumes, facilitando gestão

## 🔧 Comandos Úteis

### Listar subvolumes
```bash
sudo btrfs subvolume list /
```

### Criar snapshot manual
```bash
# Snapshot do home
sudo btrfs subvolume snapshot /home /.snapshots/home-$(date +%Y%m%d-%H%M%S)

# Snapshot do persist
sudo btrfs subvolume snapshot /persist /.snapshots/persist-$(date +%Y%m%d-%H%M%S)

# Snapshot dos containers
sudo btrfs subvolume snapshot /var/lib/containers /.snapshots/containers-$(date +%Y%m%d-%H%M%S)
```

### Ver uso de espaço por subvolume
```bash
sudo btrfs filesystem usage /
sudo btrfs qgroup show /
```

### Estatísticas de compressão
```bash
sudo compsize /
sudo compsize /home
sudo compsize /var/lib/flatpak
```

### Desfragmentar subvolumes
```bash
# Desfragmentar com recompressão
sudo btrfs filesystem defragment -r -czstd /home
sudo btrfs filesystem defragment -r -czstd /var/lib/flatpak
```

## 📊 Vantagens da Estrutura

### ✅ **Isolamento**
- Cada tipo de dado em seu próprio subvolume
- Falhas isoladas (e.g., problema no Flatpak não afeta containers)
- Políticas de backup diferenciadas

### ✅ **Snapshots Granulares**
- Snapshot apenas do `/home` sem incluir containers
- Backup de configurações (`@persist`) independente de aplicações
- Restauração seletiva

### ✅ **Performance**
- Compressão desabilitada em `/var/log` (logs já comprimidos)
- Otimizações específicas por tipo de dado
- Menos fragmentação

### ✅ **Manutenção**
- Limpeza seletiva de subvolumes
- Quota por subvolume (se necessário)
- Fácil migração de dados

### ✅ **Impermanence**
- Sistema sempre limpo no boot
- Apenas dados explicitamente preservados são mantidos
- Reduz drift de configuração

## 🔒 Integração com Impermanence

Exemplo de configuração do impermanence para usar `@persist`:

```nix
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/systemd"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.seu-usuario = {
      directories = [
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        ".ssh"
        ".gnupg"
        ".local/share/keyrings"
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
```

## 🐳 Flatpak e Containers

### Configuração Flatpak
```nix
{
  services.flatpak.enable = true;
  # O subvolume @flatpak já está montado em /var/lib/flatpak
}
```

### Configuração Podman
```nix
{
  virtualisation.podman = {
    enable = true;
    # O subvolume @containers já está montado em /var/lib/containers
    defaultNetwork.settings.dns_enabled = true;
  };
}
```

### Configuração Docker (alternativa)
```nix
{
  virtualisation.docker = {
    enable = true;
    # O subvolume @containers já está montado em /var/lib/containers
    storageDriver = "btrfs";
  };
}
```

## 📝 Nomenclatura @ (Estilo Ubuntu/Debian)

A convenção `@` é amplamente adotada:
- **@**: Raiz do sistema
- **@home**: Diretório home
- **@nix**: Store do Nix (específico NixOS)
- **@persist**: Dados persistentes (impermanence)
- **@containers**: Dados de containers (Podman, Docker)
- **@flatpak**: Aplicações Flatpak
- **@log**: Logs do sistema
- **@snapshots**: Backups e snapshots

Vantagens:
- Compatível com ferramentas como Timeshift
- Fácil identificação visual
- Padrão amplamente reconhecido
- Simplicidade em scripts de backup

## 🔄 Migração de Dados Existentes

Se já tem dados em subvolumes antigos:

```bash
# 1. Boot em live USB
# 2. Monte o Btrfs root
sudo mount /dev/mapper/crypted /mnt

# 3. Renomeie os subvolumes antigos
sudo mv /mnt/root /mnt/@
sudo mv /mnt/home /mnt/@home
sudo mv /mnt/nix /mnt/@nix
sudo mv /mnt/persist /mnt/@persist

# 4. Crie novos subvolumes
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@containers
sudo btrfs subvolume create /mnt/@flatpak
sudo btrfs subvolume create /mnt/@snapshots

# 5. Atualize fstab e reinstale bootloader
```

## 📚 Referências

- [Btrfs Wiki - SysadminGuide](https://btrfs.wiki.kernel.org/index.php/SysadminGuide)
- [NixOS Wiki - Impermanence](https://nixos.wiki/wiki/Impermanence)
- [Arch Wiki - Btrfs](https://wiki.archlinux.org/title/Btrfs)
- [Impermanence GitHub](https://github.com/nix-community/impermanence)
