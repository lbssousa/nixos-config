# Módulo comum: Impermanence
{ config, lib, pkgs, ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/lib/systemd"
      "/var/lib/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.laercio = {
      directories = [
        "Downloads"
        "Documents"
        ".ssh"
        ".local/share/keyrings"
        ".mozilla"
        ".config/gh"
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
