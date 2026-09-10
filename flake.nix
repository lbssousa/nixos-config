{
  description = "NixOS configuration with Btrfs, preservation, and hybrid swap";

  inputs = {
    # NixOS unstable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # flake-parts for modular flake composition
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts?rev=3107b77cd68437b9a76194f0f7f9c55f2329ca5b&shallow=1";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Preservation for ephemeral root
    preservation.url = "github:nix-community/preservation";

    # NixOS hardware profiles
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # sops-nix for secret management (Wi-Fi passwords, etc.)
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Separate repository with the SOPS/age secrets
    nix-secrets = {
      url = "git+ssh://git@github.com/lbssousa/nix-secrets?shallow=1";
      flake = true;
    };

    # nix-flatpak for declarative Flatpaks with no nixpkgs equivalent
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";

    # nix-linuxbrew — NixOS + Home Manager modules for Homebrew on Linux
    nix-linuxbrew = {
      url = "github:deepwatrcreatur/nix-linuxbrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim for declarative Neovim configuration
    nixvim.url = "github:nix-community/nixvim";

    # nix-wrapper-modules — packages programs with config baked into the store
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    # gregorio-lsp, grefmt, grelint — Gregorio GABC/NABC LSP, formatter and linter
    gregorio-lsp = {
      url = "github:AISCGre-BR/gregorio-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Noctalia desktop suite ──────────────────────────────────────────────
    # Umbriel: independent wlroots Wayland compositor
    umbriel.url = "github:noctalia-dev/umbriel";
    # Noctalia Shell: bars, launcher, dock, notifications, OSDs, lock screen
    noctalia.url = "github:noctalia-dev/noctalia";
    # Noctalia Greeter: login greeter for greetd
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = import ./dendritic/imports.nix {
        root = ./dendritic;
        inherit (inputs.nixpkgs) lib;
      };

      systems = [ "x86_64-linux" ];
    };
}
