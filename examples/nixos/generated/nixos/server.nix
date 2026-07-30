{ ... }:

{
  imports = [ ];
  boot.loader.grub.devices = [ "nodev" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  system.stateVersion = "26.11";
}
