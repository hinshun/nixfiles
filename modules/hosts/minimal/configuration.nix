{ nixosModules, ... }:
{
  imports = [ nixosModules.cloud-minimal ];

  networking.hostName = "nixos";
  system.stateVersion = "25.11";
}
