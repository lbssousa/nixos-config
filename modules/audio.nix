# Módulo comum: Audio (PipeWire)
{ config, lib, pkgs, ... }:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = true;
    jack.enable = lib.mkDefault true;
  };
}
