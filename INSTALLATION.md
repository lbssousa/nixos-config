# Guia de Instalação do NixOS

Este guia cobre a instalação do NixOS usando esta configuração baseada em Flakes com disko, impermanence e swap híbrida.

## 📋 Pré-requisitos

1. Baixe a ISO do NixOS: https://nixos.org/download.html
2. Crie um USB bootável com a ISO
3. Boot no USB

## 🚀 Instalação

### 1. Preparar o ambiente

```bash
# Conectar à internet (se necessário)
# Para Wi-Fi:
sudo systemctl start wpa_supplicant
wpa_cli

# Definir layout do teclado
loadkeys br-abnt2

# Ativar SSH (opcional, para instalação remota)
sudo systemctl start sshd
passwd # Definir senha temporária

# Habilitar Flakes temporariamente
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Clonar o repositório

```bash
# Instalar git no live environment
nix-shell -p git

# Clonar a configuração
git clone https://github.com/lbssousa/nixos-config.git /tmp/nixos-config
cd /tmp/nixos-config
```

### 3. Ajustar configuração de disco

Edite o arquivo de disko do host desejado para definir o dispositivo correto:

```bash
# Para barbudus:
nano hosts/barbudus/disko.nix

# Para bigodon:
nano hosts/bigodon/disko.nix

# Para nixbox:
nano hosts/nixbox/disko.nix
```

Altere a linha `device = "/dev/nvme0n1"` (ou `/dev/sda` para nixbox) para o disco correto.

**Encontrar o disco:**
```bash
lsblk
# ou
fdisk -l
```

### 4. Particionar e formatar o disco

⚠️ **ATENÇÃO**: Este comando IRÁ APAGAR TODOS OS DADOS DO DISCO!

```bash
# Escolha o host apropriado (barbudus, bigodon ou nixbox)
HOST=barbudus

# Executar disko para particionar e formatar
sudo nix run github:nix-community/disko -- --mode disko ./hosts/$HOST/disko.nix
```

Este comando irá:
- Criar partições GPT (EFI, LUKS+LVM)
- Configurar criptografia LUKS
- Criar volumes LVM (swap + btrfs)
- Criar subvolumes Btrfs (@, @home, @nix, @persist, etc.)
- Montar tudo em `/mnt`

### 5. Gerar configuração de hardware

```bash
# Gerar hardware-configuration.nix
nixos-generate-config --no-filesystems --root /mnt

# Mover para o diretório do host
sudo mv /mnt/etc/nixos/hardware-configuration.nix ./hosts/$HOST/

# Editar e adicionar import do disko.nix e configuração zram
nano ./hosts/$HOST/hardware-configuration.nix

# Adicionar no início dos imports:
#   (import ./disko.nix { inherit lib; })
#
# E adicionar as seções de zramSwap e boot.kernel.sysctl
# conforme os exemplos nos outros hosts
```

### 6. Instalar o NixOS

```bash
# Copiar configuração para /mnt/etc/nixos
sudo mkdir -p /mnt/etc/nixos
sudo cp -r . /mnt/etc/nixos/

# Instalar o sistema
sudo nixos-install --flake /mnt/etc/nixos#$HOST

# Durante a instalação, será solicitado:
# 1. Senha de criptografia LUKS (use a mesma que vai usar para login)
# 2. Senha do usuário root
```

### 7. Configurar senha do usuário

```bash
# Definir senha para o usuário laercio
sudo nixos-enter --root /mnt
passwd laercio
exit
```

### 8. Finalizar

```bash
# Desmontar e reiniciar
sudo umount -R /mnt
sudo reboot
```

## 🔐 Primeiro Boot

1. **Desbloqueio LUKS**: Digite a senha de criptografia
2. **Login**: Use o usuário `laercio` e a senha definida
3. **Verificar sistema**:
   ```bash
   # Ver subvolumes Btrfs
   sudo btrfs subvolume list /
   
   # Ver swap
   swapon --show
   zramctl
   
   # Ver uso de disco
   df -h
   ```

## 📝 Pós-instalação

### Atualizar o sistema

```bash
# Atualizar flake.lock
sudo nix flake update /etc/nixos

# Rebuildar sistema
sudo nixos-rebuild switch --flake /etc/nixos#$HOST
```

### Configurar SSH keys

```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu-email@example.com"

# As chaves serão preservadas em /persist via impermanence
```

### Configurar GPG keys

```bash
# Importar chaves GPG existentes
gpg --import sua-chave-privada.asc

# As chaves serão preservadas em /persist via impermanence
```

### Instalar mais aplicações

Edite `home.nix` ou `configuration.nix` do seu host e adicione pacotes:

```nix
# Em home.nix
home.packages = with pkgs; [
  firefox
  vscode
  # ...
];
```

Então reconstrua:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#$HOST
```

## 🔧 Solução de Problemas

### Erro ao montar subvolumes

Se os subvolumes não montarem corretamente:

```bash
# Verificar subvolumes existentes
sudo mount /dev/mapper/root_vg-root /mnt
sudo btrfs subvolume list /mnt

# Criar subvolumes faltantes manualmente se necessário
sudo btrfs subvolume create /mnt/@log
```

### Problemas com LUKS

```bash
# Abrir LUKS manualmente
sudo cryptsetup open /dev/nvme0n1p3 crypted

# Ativar LVM
sudo vgchange -ay
```

### Sistema não boota (impermanence)

Se o sistema não boota devido a arquivos faltantes:

1. Boot no USB live
2. Monte os volumes:
   ```bash
   sudo cryptsetup open /dev/nvme0n1p3 crypted
   sudo vgchange -ay
   sudo mount -o subvol=@ /dev/mapper/root_vg-root /mnt
   sudo mount -o subvol=@persist /dev/mapper/root_vg-root /mnt/persist
   sudo mount /dev/nvme0n1p2 /mnt/boot
   ```
3. Entre no sistema:
   ```bash
   sudo nixos-enter --root /mnt
   ```
4. Corrija a configuração de impermanence

### Redefinir senha LUKS

```bash
# Boot no USB live
sudo cryptsetup open /dev/nvme0n1p3 crypted

# Adicionar nova senha
sudo cryptsetup luksAddKey /dev/nvme0n1p3

# Remover senha antiga (slot 0)
sudo cryptsetup luksRemoveKey /dev/nvme0n1p3
```

## 📚 Referências

- [Manual do NixOS](https://nixos.org/manual/nixos/stable/)
- [Disko](https://github.com/nix-community/disko)
- [Impermanence](https://github.com/nix-community/impermanence)
- [Home Manager](https://github.com/nix-community/home-manager)

## 🆘 Suporte

Para problemas específicos desta configuração, abra uma issue no GitHub:
https://github.com/lbssousa/nixos-config/issues
