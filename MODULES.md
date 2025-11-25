# Estrutura Modular da Configuração

Este documento explica a arquitetura modular do projeto e como os módulos se organizam.

## 🎯 Filosofia da Modularização

A configuração foi modularizada para:

1. **Reduzir duplicação**: Código comum em um único lugar
2. **Facilitar manutenção**: Mudanças propagam automaticamente
3. **Melhorar legibilidade**: Cada módulo tem responsabilidade única
4. **Permitir reuso**: Módulos podem ser combinados de diferentes formas

## 📦 Módulos Disponíveis

### `modules/common.nix`
**Configurações básicas do sistema**

- Bootloader (systemd-boot)
- Kernel parameters padrão
- NetworkManager
- Localização (BR)
- X11 básico
- Configurações do Nix (flakes, auto-optimise, gc)
- System state version

**Usado por**: Todos os hosts

### `modules/audio.nix`
**Sistema de áudio com PipeWire**

- PipeWire habilitado
- Suporte ALSA e PulseAudio
- Suporte JACK (desktops)
- RTKit para baixa latência

**Usado por**: Todos os hosts

### `modules/containers.nix`
**Containers e virtualização**

- Podman habilitado (modo rootless)
- Compatibilidade Docker
- DNS habilitado para containers
- Ferramentas: dive, podman-tui, podman-compose

**Usado por**: Todos os hosts

### `modules/impermanence.nix`
**Configuração de persistência**

- Diretórios do sistema preservados
- Chaves SSH preservadas
- Diretórios do usuário preservados
- Arquivos de configuração preservados

**Usado por**: Todos os hosts

### `modules/packages.nix`
**Pacotes essenciais do sistema**

- Ferramentas básicas: git, vim, wget, curl
- Utilitários: htop, pciutils, usbutils

**Usado por**: Todos os hosts

### `modules/ssh.nix`
**Servidor SSH**

- OpenSSH habilitado
- Autenticação por senha desabilitada (padrão)
- Chaves do host em /persist

**Usado por**: Todos os hosts

### `modules/users.nix`
**Usuário padrão do sistema**

- Usuário: laercio
- Grupos: networkmanager, wheel, video, audio
- Senha inicial: changeme

**Usado por**: Todos os hosts

### `modules/desktop.nix`
**Recursos específicos de desktops físicos**

- Bluetooth + blueman
- Impressão (CUPS)
- Flatpak
- Pastas de mídia preservadas (Pictures, Videos, Music)

**Usado por**: barbudus, bigodon (não nixbox)

## 🏗️ Estrutura dos Hosts

### barbudus (Dell Inspiron 14 5490)
```nix
imports = [
  ../../modules/common.nix
  ../../modules/audio.nix
  ../../modules/containers.nix
  ../../modules/impermanence.nix
  ../../modules/packages.nix
  ../../modules/ssh.nix
  ../../modules/users.nix
  ../../modules/desktop.nix  # Desktop físico
];

# Configurações específicas:
# - Nvidia PRIME offload
# - Hardware híbrido Intel + Nvidia
```

### bigodon (Morefine M6)
```nix
imports = [
  ../../modules/common.nix
  ../../modules/audio.nix
  ../../modules/containers.nix
  ../../modules/impermanence.nix
  ../../modules/packages.nix
  ../../modules/ssh.nix
  ../../modules/users.nix
  ../../modules/desktop.nix  # Desktop físico
];

# Configurações específicas:
# - Intel Graphics (modesetting)
# - Mais simples que barbudus
```

### nixbox (VirtualBox VM)
```nix
imports = [
  ../../modules/common.nix
  ../../modules/audio.nix
  ../../modules/containers.nix
  ../../modules/impermanence.nix
  ../../modules/packages.nix
  ../../modules/ssh.nix
  ../../modules/users.nix
  # NÃO usa desktop.nix (é VM)
];

# Configurações específicas:
# - VirtualBox guest additions
# - SSH com senha habilitada
# - Audio simplificado (sem 32-bit, sem JACK)
# - Grupo vboxsf
```

## 🔧 Como Adicionar Novo Módulo

1. **Criar arquivo em `modules/`**:
   ```nix
   # modules/novo-modulo.nix
   { config, lib, pkgs, ... }:
   
   {
     # Suas configurações aqui
   }
   ```

2. **Importar nos hosts necessários**:
   ```nix
   imports = [
     ../../modules/comum.nix
     ../../modules/novo-modulo.nix  # Adicionar aqui
   ];
   ```

3. **Usar lib.mkDefault para valores padrão**:
   ```nix
   services.exemplo.enable = lib.mkDefault true;
   ```

4. **Hosts podem sobrescrever com lib.mkForce**:
   ```nix
   services.exemplo.enable = lib.mkForce false;
   ```

## 🎨 Padrões de Uso

### Configuração padrão que pode ser sobrescrita
```nix
# No módulo
boot.kernelParams = lib.mkDefault [
  "quiet"
  "splash"
];

# No host (adicionar parâmetros)
boot.kernelParams = [
  "nvidia-drm.modeset=1"
];
```

### Sobrescrever completamente
```nix
# No host
services.openssh.settings.PasswordAuthentication = lib.mkForce true;
```

### Estender configuração
```nix
# No módulo
environment.persistence."/persist".directories = [
  "/etc/nixos"
];

# No host (módulo desktop.nix adiciona mais)
environment.persistence."/persist".directories = [
  "/var/lib/bluetooth"
];
```

## 📊 Benefícios da Estrutura Atual

### ✅ Redução de Código
- **Antes**: ~180 linhas por host
- **Depois**: ~50 linhas por host
- **Redução**: ~70% de código duplicado

### ✅ Manutenção Simplificada
- Mudar SSH em um lugar → Afeta todos os hosts
- Adicionar pacote comum → Um único arquivo
- Atualizar PipeWire → Propagação automática

### ✅ Clareza
- Cada host mostra apenas o que é único
- Fácil identificar diferenças entre hosts
- Módulos auto-documentados

### ✅ Reusabilidade
- Criar novo host = escolher módulos + configurações específicas
- Módulos podem ser compartilhados entre projetos
- Fácil criar "perfis" (desktop, server, minimal)

## 🔄 Fluxo de Configuração

```
flake.nix
  └── hosts/barbudus/
      ├── hardware-configuration.nix (disko + zram)
      └── configuration.nix
          ├── imports modules/common.nix
          ├── imports modules/audio.nix
          ├── imports modules/containers.nix
          ├── imports modules/impermanence.nix
          ├── imports modules/packages.nix
          ├── imports modules/ssh.nix
          ├── imports modules/users.nix
          ├── imports modules/desktop.nix
          └── configurações específicas (nvidia, etc.)
```

## 🚀 Expansão Futura

Módulos que podem ser adicionados:

- `modules/nvidia.nix` - Configuração Nvidia isolada
- `modules/gaming.nix` - Steam, gamemode, etc.
- `modules/development.nix` - Ferramentas de dev
- `modules/desktop-gnome.nix` - Desktop GNOME
- `modules/desktop-kde.nix` - Desktop KDE
- `modules/virtualisation.nix` - VMs (não containers)
- `modules/server.nix` - Configurações de servidor
- `modules/minimal.nix` - Sistema minimalista

## 💡 Dicas

1. **Um conceito por módulo**: Cada módulo deve ter uma responsabilidade clara
2. **Use lib.mkDefault**: Permite hosts sobrescreverem facilmente
3. **Documente dependências**: Se um módulo precisa de outro, documente
4. **Teste isoladamente**: Cada módulo deve funcionar independentemente
5. **Evite hardcoding**: Use variáveis e opções quando possível

## 📚 Referências

- [NixOS Module System](https://nixos.wiki/wiki/Module)
- [NixOS Manual - Modules](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [lib.mkDefault vs lib.mkForce](https://nixos.org/manual/nixos/stable/index.html#sec-option-definitions)
