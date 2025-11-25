# nixos-config

Configuração pessoal do NixOS baseada em Flakes, com particionamento declarativo (disko), sistema ephemeral (impermanence), subvolumes Btrfs otimizados e swap híbrida.

## 🎯 Características

- ✅ **Nix Flakes**: Configuração reproduzível e declarativa
- ✅ **Disko**: Particionamento declarativo de disco
- ✅ **LUKS + LVM**: Criptografia completa do disco
- ✅ **Btrfs**: Sistema de arquivos moderno com compressão zstd
- ✅ **Impermanence**: Sistema ephemeral, limpo a cada boot
- ✅ **Swap híbrida**: zram + swap em disco para máxima performance
- ✅ **Subvolumes otimizados**: Isolamento para Flatpak, Podman e logs
- ✅ **Home Manager**: Gerenciamento de configurações de usuário
- ✅ **Multi-host**: Configurações específicas para cada máquina
- ✅ **Distrobox**: Execute qualquer distribuição Linux em containers rootless
- ✅ **Modular**: Módulos compartilhados para fácil manutenção
- ✅ **Niri**: Compositor Wayland moderno com scrollable tiling
- ✅ **QuickShell**: Barra de status personalizável
- ✅ **Ghostty**: Terminal acelerado por GPU

## 🖥️ Hosts Suportados

### barbudus
- **Hardware**: Dell Inspiron 14 5490
- **CPU**: Intel i5-10210U
- **RAM**: 16 GB
- **GPU**: Intel + Nvidia GeForce MX230 (PRIME offload)
- **Swap**: 20 GB em disco + 8 GB zram

### bigodon
- **Hardware**: Morefine M6 Mini-PC
- **CPU**: Intel N200
- **RAM**: 16 GB
- **GPU**: Intel UHD Graphics
- **Swap**: 20 GB em disco + 8 GB zram

### nixbox
- **Hardware**: VirtualBox VM
- **RAM**: 16 GB (virtual)
- **Swap**: Apenas 16 GB zram (sem swap em disco)

## 📁 Estrutura do Projeto

```
.
├── flake.nix                 # Entrada principal do Flake
├── flake.lock                # Lockfile das dependências
├── home.nix                  # Configuração Home Manager
├── disko.nix                 # Template base de particionamento
├── hosts/                    # Configurações específicas por host
│   ├── barbudus/
│   │   ├── configuration.nix        # Config específica (Nvidia, etc.)
│   │   ├── hardware-configuration.nix # Hardware + disko + swap
│   │   └── disko.nix                # Parâmetros do disko
│   ├── bigodon/
│   │   └── ...
│   └── nixbox/
│       └── ...
├── modules/                  # Módulos compartilhados
│   ├── common.nix            # Configurações básicas (boot, locale, nix)
│   ├── audio.nix             # PipeWire
│   ├── containers.nix        # Podman + Distrobox
│   ├── impermanence.nix      # Configuração de persistência
│   ├── packages.nix          # Pacotes essenciais
│   ├── ssh.nix               # Servidor SSH
│   ├── users.nix             # Usuário padrão
│   ├── desktop.nix           # Bluetooth, impressão, Flatpak
│   ├── niri.nix              # Compositor Niri + Wayland
│   └── wayland-apps.nix      # Ghostty, NetworkManager, ferramentas
├── INSTALLATION.md           # Guia de instalação detalhado
├── NIXOS_CONFIG_SPECS.md     # Especificações do projeto
├── BTRFS_SUBVOLUMES.md       # Documentação dos subvolumes
├── SWAP_CONFIG.md            # Documentação da swap híbrida
├── DISTROBOX.md              # Guia de uso do Distrobox
└── README.md                 # Este arquivo
```

## 🚀 Início Rápido

### Instalação

Veja o [Guia de Instalação Completo](INSTALLATION.md) para instruções detalhadas.

**Resumo:**
```bash
# 1. Boot no USB do NixOS
# 2. Clonar este repositório
git clone https://github.com/lbssousa/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config

# 3. Ajustar device no disko.nix do host
nano hosts/barbudus/disko.nix  # ou bigodon/nixbox

# 4. Particionar e instalar
sudo nix run github:nix-community/disko -- --mode disko ./hosts/barbudus/disko.nix
sudo nixos-install --flake .#barbudus
```

### Atualização

```bash
# Atualizar flake inputs
sudo nix flake update

# Rebuildar sistema
sudo nixos-rebuild switch --flake .#barbudus
```

### Rollback

```bash
# Listar gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Voltar para geração anterior
sudo nixos-rebuild switch --rollback
```

## 📚 Documentação

- **[INSTALLATION.md](INSTALLATION.md)**: Guia completo de instalação
- **[NIXOS_CONFIG_SPECS.md](NIXOS_CONFIG_SPECS.md)**: Especificações e requisitos
- **[BTRFS_SUBVOLUMES.md](BTRFS_SUBVOLUMES.md)**: Estrutura de subvolumes Btrfs
- **[SWAP_CONFIG.md](SWAP_CONFIG.md)**: Configuração de swap híbrida
- **[DISTROBOX.md](DISTROBOX.md)**: Guia de uso do Distrobox

## 🔧 Customização

### Adicionar novo host

1. Criar diretório: `mkdir -p hosts/novo-host`
2. Copiar arquivos base de um host existente
3. Ajustar `configuration.nix`, `disko.nix` e `hardware-configuration.nix`
4. Adicionar ao `flake.nix`:
   ```nix
   nixosConfigurations.novo-host = nixpkgs.lib.nixosSystem {
     # ...
   };
   ```

### Modificar subvolumes Btrfs

Edite `disko.nix` base e ajuste a seção `subvolumes`:
```nix
subvolumes = {
  "/@novo" = {
    mountpoint = "/novo";
    mountOptions = ["subvol=@novo" "compress=zstd" "noatime"];
  };
};
```

### Adicionar pacotes

Em `home.nix` (usuário):
```nix
home.packages = with pkgs; [
  firefox
  vscode
];
```

Ou em `configuration.nix` (sistema):
```nix
environment.systemPackages = with pkgs; [
  vim
  git
];
```

## 🛠️ Comandos Úteis

```bash
# Verificar configuração
nix flake check

# Ver informações do flake
nix flake show

# Atualizar apenas um input
nix flake lock --update-input nixpkgs

# Ver tamanho do Nix store
nix path-info -rsSh /run/current-system

# Limpar gerações antigas
sudo nix-collect-garbage --delete-older-than 30d

# Ver subvolumes Btrfs
sudo btrfs subvolume list /

# Ver uso de swap
swapon --show
zramctl

# Distrobox - criar container
distrobox create --name archlinux --image archlinux:latest
distrobox enter archlinux
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para:
- Reportar bugs
- Sugerir melhorias
- Enviar pull requests

## 📄 Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

## 🙏 Agradecimentos

- [NixOS](https://nixos.org/)
- [Disko](https://github.com/nix-community/disko)
- [Impermanence](https://github.com/nix-community/impermanence)
- [Home Manager](https://github.com/nix-community/home-manager)
- Comunidade NixOS

## 📞 Contato

**Laércio de Sousa**
- Email: laercio@sivali.sousa.nom.br
- GitHub: [@lbssousa](https://github.com/lbssousa)
