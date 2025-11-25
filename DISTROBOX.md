# Distrobox no NixOS

Este guia explica como usar o Distrobox para executar qualquer distribuição Linux dentro de containers Podman em modo rootless.

## 🎯 O que é Distrobox?

Distrobox é um wrapper para Podman/Docker que permite executar qualquer distribuição Linux dentro do seu terminal, com integração perfeita ao sistema host. É ideal para:

- Usar software não disponível no NixOS
- Testar diferentes distribuições
- Desenvolvimento com ambientes específicos
- Executar aplicações GUI de outras distros

## ✅ Configuração

A configuração já está habilitada neste sistema:

### Sistema (configuration.nix)
```nix
# Enable common container config files in /etc/containers
virtualisation.containers.enable = true;

# Enable Podman for rootless containers
virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  defaultNetwork.settings.dns_enabled = true;
};
```

### Usuário (home.nix)
```nix
home.packages = with pkgs; [
  distrobox
];
```

## 🚀 Uso Básico

### Criar um container

```bash
# Arch Linux
distrobox create --name archlinux --image archlinux:latest

# Ubuntu
distrobox create --name ubuntu --image ubuntu:latest

# Fedora
distrobox create --name fedora --image fedora:latest

# Alpine Linux
distrobox create --name alpine --image alpine:latest

# Debian
distrobox create --name debian --image debian:latest
```

### Entrar no container

```bash
distrobox enter archlinux
```

### Listar containers

```bash
distrobox list
```

### Parar container

```bash
distrobox stop archlinux
```

### Remover container

```bash
distrobox rm archlinux
```

## 🖥️ Usando Aplicações GUI

### Wayland (padrão)

Com Wayland, as aplicações GUI funcionam automaticamente sem configuração adicional. O Distrobox compartilha automaticamente o socket do Wayland com os containers.

```bash
# Variáveis de ambiente já configuradas:
# - WAYLAND_DISPLAY
# - XDG_RUNTIME_DIR
# - DISPLAY (para compatibilidade X11/XWayland)
```

### Instalar e exportar aplicação GUI

```bash
# Entrar no container
distrobox enter ubuntu

# Instalar aplicação (exemplo: GIMP)
sudo apt update
sudo apt install gimp

# Exportar para o menu de aplicações do NixOS
distrobox-export --app gimp

# Sair do container
exit
```

Agora o GIMP aparecerá no seu launcher de aplicações!

## 🔧 Problemas de Permissão

Se encontrar erros de permissão ao instalar ou executar pacotes:

### Criar container com volumes específicos

```bash
distrobox create \
  --image ubuntu:latest \
  --name ubuntu \
  --home /home/ubuntu-distro \
  --volume /etc/static/profiles/per-user:/etc/profiles/per-user:ro \
  --verbose
```

### Verificar mapeamento de usuário

```bash
# Verificar subuid e subgid
cat /etc/subuid
cat /etc/subgid

# No NixOS, isso é gerenciado automaticamente pelo Podman
```

## 📦 Exemplos de Uso

### Container de desenvolvimento Python (Ubuntu)

```bash
# Criar container
distrobox create --name dev-python --image ubuntu:22.04

# Entrar
distrobox enter dev-python

# Instalar ferramentas
sudo apt update
sudo apt install python3 python3-pip python3-venv build-essential

# Trabalhar normalmente
cd ~/Projects/meu-projeto
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Container AUR (Arch Linux)

```bash
# Criar container Arch
distrobox create --name arch-aur --image archlinux:latest

# Entrar
distrobox enter arch-aur

# Instalar yay (AUR helper)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Instalar pacotes do AUR
yay -S spotify
distrobox-export --app spotify
```

### Container para testes (Alpine)

```bash
# Criar container Alpine (pequeno e rápido)
distrobox create --name test --image alpine:latest

# Entrar
distrobox enter test

# Instalar pacotes
sudo apk add nodejs npm
```

## 🎨 Integração Avançada

### Exportar binários

```bash
# Dentro do container
distrobox-export --bin /usr/bin/code --export-path ~/.local/bin

# Agora 'code' estará disponível no PATH do host
```

### Exportar serviços systemd

```bash
# Dentro do container
distrobox-export --service nginx --extra-flags "-p 8080:80"
```

### Usar home directory compartilhado

```bash
# Por padrão, ~/  é compartilhado entre host e container
# Arquivos em ~ são acessíveis de ambos os lados
```

## 🔐 Segurança

### Containers rootless

- Containers executam sem privilégios de root
- Usa user namespaces do kernel
- Isolamento entre containers e host
- Mapeamento de UID/GID automático

### Boas práticas

```bash
# 1. Não execute containers como root (padrão já é rootless)
# 2. Limite recursos se necessário
distrobox create --name limited \
  --image ubuntu:latest \
  --memory 2g \
  --cpus 2

# 3. Use volumes read-only quando possível
distrobox create --name secure \
  --image alpine:latest \
  --volume /dados/publicos:/data:ro
```

## 🐛 Solução de Problemas

### Container não inicia

```bash
# Verificar logs do Podman
podman logs <container-id>

# Recriar container
distrobox rm problema
distrobox create --name problema --image ubuntu:latest
```

### Problemas de rede

```bash
# Verificar DNS
distrobox enter mycontainer
ping 8.8.8.8
ping google.com

# Se DNS não funcionar, recriar com:
distrobox create --name mycontainer --image ubuntu:latest --init
```

### Aplicações GUI não funcionam

```bash
# Verificar variáveis de ambiente Wayland
echo $WAYLAND_DISPLAY
echo $XDG_RUNTIME_DIR
echo $DISPLAY

# Dentro do container
distrobox enter mycontainer
echo $WAYLAND_DISPLAY  # Deve ser o mesmo
echo $XDG_RUNTIME_DIR  # Deve ser o mesmo

# Para aplicações X11, verificar se XWayland está rodando
ps aux | grep Xwayland

# Recriar container se necessário
distrobox rm mycontainer
distrobox create --name mycontainer --image ubuntu:latest --init
```

### Espaço em disco

```bash
# Limpar imagens não usadas
podman image prune -a

# Limpar containers parados
podman container prune

# Ver uso de espaço
podman system df
```

## 📊 Comandos Úteis

```bash
# Ver todas as imagens disponíveis
podman images

# Ver containers em execução
podman ps

# Ver todos os containers (incluindo parados)
podman ps -a

# Atualizar imagem
podman pull ubuntu:latest
distrobox upgrade ubuntu

# Backup de container
distrobox-export --backup mycontainer

# Ver informações do container
distrobox enter mycontainer
cat /etc/os-release
uname -a
```

## 🎓 Recursos Adicionais

- [Documentação oficial do Distrobox](https://distrobox.it/)
- [NixOS Wiki - Distrobox](https://nixos.wiki/wiki/Distrobox)
- [NixOS Wiki - Podman](https://nixos.wiki/wiki/Podman)
- [Podman Documentation](https://docs.podman.io/)

## 💡 Dicas

1. **Performance**: Containers compartilham o kernel do host, então são muito rápidos
2. **Persistência**: Dados em `~/.local/share/containers/` são preservados
3. **Impermanence**: Com este sistema, containers são preservados no subvolume `@containers`
4. **Multi-distro**: Você pode ter múltiplas distros rodando simultaneamente
5. **Não é VM**: Diferente de VMs, containers compartilham recursos do host
6. **Wayland**: Aplicações GUI funcionam nativamente com Wayland, X11 via XWayland
6. **Wayland**: Aplicações GUI funcionam nativamente com Wayland, X11 via XWayland

## ⚠️ Limitações

- Não pode rodar kernels diferentes
- Não pode modificar módulos do kernel
- Alguns drivers específicos podem não funcionar
- Aplicações que precisam de acesso direto ao hardware podem ter problemas

## 🔄 Migração de Docker

Se você usava Docker antes:

```bash
# Podman é compatível com Docker
alias docker=podman
alias docker-compose=podman-compose

# Importar imagens Docker
podman load < imagem-docker.tar

# Converter docker-compose.yml funciona diretamente
podman-compose up -d
```
