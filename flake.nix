{
  description = "NixOS configuration with impermanence, Btrfs subvolumes, and hybrid swap";

  inputs = {
    # NixOS unstable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    # Impermanence for ephemeral root
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, impermanence, ... }@inputs: {
    # NixOS configurations
    nixosConfigurations = {
      # Dell Inspiron 14 5490 (Intel i5-10210U, 16GB RAM, Intel + Nvidia MX230)
      barbudus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Disko configuration
          disko.nixosModules.disko

          # Hardware configuration (includes disko and swap)
          ./hosts/barbudus/hardware-configuration.nix

          # Main configuration
          ./hosts/barbudus/configuration.nix

          # Impermanence
          impermanence.nixosModules.impermanence

          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.laercio = import ./home.nix;
          }
        ];
      };

      # Morefine M6 (Intel N200, 16GB RAM, Intel UHD Graphics)
      bigodon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Disko configuration
          disko.nixosModules.disko

          # Hardware configuration (includes disko and swap)
          ./hosts/bigodon/hardware-configuration.nix

          # Main configuration
          ./hosts/bigodon/configuration.nix

          # Impermanence
          impermanence.nixosModules.impermanence

          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.laercio = import ./home.nix;
          }
        ];
      };

      # VirtualBox VM
      nixbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # Disko configuration
          disko.nixosModules.disko

          # Hardware configuration (includes disko and swap)
          ./hosts/nixbox/hardware-configuration.nix

          # Main configuration
          ./hosts/nixbox/configuration.nix

          # Impermanence
          impermanence.nixosModules.impermanence

          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.laercio = import ./home.nix;
          }
        ];
      };
    };

    # Expose disko configuration for installation
    diskoConfigurations = {
      barbudus = import ./hosts/barbudus/disko.nix { inherit (nixpkgs) lib; };
      bigodon = import ./hosts/bigodon/disko.nix { inherit (nixpkgs) lib; };
      nixbox = import ./hosts/nixbox/disko.nix { inherit (nixpkgs) lib; };
    };
  };
}
