{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  swapSize ? "8G",
  lib,
  ...
}: let
  hasSwap = swapSize != "0" && swapSize != "";
in {
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = lib.mkMerge [
          (lib.mkIf hasSwap {
            swap = {
              size = swapSize;
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          })
          {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                subvolumes = {
                  # Subvolume raiz - ephemeral, limpo a cada boot (impermanence)
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  # Diretórios de usuário - preservados
                  "@home" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/home";
                  };

                  # Nix store - preservado (essencial)
                  "@nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
                  };

                  # Dados persistentes do sistema - preservados
                  "@persist" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/persist";
                  };

                  # Logs do sistema - preservados, sem compressão (já comprimidos)
                  "@log" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/var/log";
                  };

                  # Dados de containers (Podman, Docker, etc.) - preservados
                  "@containers" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/var/lib/containers";
                  };

                  # Dados de Flatpak - preservados
                  "@flatpak" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/var/lib/flatpak";
                  };

                  # Snapshots - para backups futuros
                  "@snapshots" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/.snapshots";
                  };
                };
              };
            };
          }
        ];
      };
    };
  };
}
