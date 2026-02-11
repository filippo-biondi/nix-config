{ config, lib, inputs, system, ... }:

let
  cfg = config.ccg.self-hosting.proxmox;
in
{
  options.ccg.self-hosting.proxmox.enable = lib.ccg.mkBoolOpt' false;

  config = lib.mkIf cfg.enable {

    nixpkgs.overlays = [
      inputs.proxmox-nixos.overlays.${system}
    ];

    services.proxmox-ve = {
      enable = true;
      ipAddress = lib.mkDefault "0.0.0.0";
    };
  };
}
