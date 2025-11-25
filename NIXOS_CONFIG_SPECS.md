# Requisitos para a configuração do NixOS

## Informações sobre os hosts alvo desta configuração

Esta configuração é destinada à instalação do NixOS nos seguintes hosts:

- **barbudus**: notebook Dell Inspiron 14 5490 (Processador Intel i5-10210U, 16 GB de RAM, placa de vídeo híbrida Intel + Nvidia GeForce MX230)
- **bigodon**: mini-PC Morefine M6 (Processador Intel N200, 16 GB de RAM, placa de vídeo Intel UHD Graphics)
- **nixbox**: máquina virtual VirtualBox

## Aspectos gerais

- A configuração deve ser baseada em Nix Flakes.
- A configuração deve usar o home-manager para as definições em nível de usuário.
- A configuração deve ser modular, multi-arquivo.
- A estrutura de diretórios da configuração do NixOS deve ser a seguinte:
```
hosts/
  barbudus/
    arquivos .nix
  bigodon/
    arquivos .nix
  nixbox/
    arquivos .nix
modules/
  ...
```

## Aspectos particulares sobre o particionamento do disco

- A configuração deve definir o esquema de particionamento de disco usando o módulo disko.
  - O sistema deverá criar as partições padrão necessárias para o UEFI, e o restante do espaço em disco deverá ser formatado com o sistema de arquivos Btrfs.
  - O sistema deverá criar as partições em um volume LVM criptografado com LUKS. A senha utilizada para descriptografar o disco será a mesma utilizada para fazer login na conta de usuário padrão do sistema.
- A configuração deverá utilizar o módulo impermanence para permitir a limpeza da partição raiz a cada boot.
  - O sistema deverá definir subvolumes Btrfs seguindo a convenção de nomenclatura @ (estilo Ubuntu/Debian):
    - **@ (/)**: Subvolume raiz ephemeral, limpo a cada boot
    - **@home (/home)**: Diretórios de usuário preservados
    - **@nix (/nix)**: Nix store preservado
    - **@persist (/persist)**: Dados persistentes do sistema
    - **@log (/var/log)**: Logs do sistema (sem compressão, pois já são comprimidos)
    - **@flatpak (/var/lib/flatpak)**: Dados de aplicações Flatpak
    - **@containers (/var/lib/containers)**: Dados de containers (Podman, Docker, etc.)
    - **@snapshots (/.snapshots)**: Armazenamento de snapshots Btrfs
  - Todos os subvolumes, exceto @log, devem ser montados com compressão zstd.
  - Com base na documentação do impermanence e nos exemplos de configuração do NixOS disponíveis no GitHub, deverá ser criado um exemplo de configuração do impermanence para definir quais diretórios e arquivos serão preservados na pasta /persist.