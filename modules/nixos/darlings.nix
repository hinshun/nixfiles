{ lib, ... }:
{
  boot = {
    # source: https://grahamc.com/blog/erase-your-darlings
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    # source: https://grahamc.com/blog/nixos-on-zfs
    kernelParams = [ "elevator=none" ];
  };

  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/docker - - - - /persist/var/lib/docker"
  ];

  fileSystems = {
    "/var/lib/bluetooth" = {
      device = "/persist/var/lib/bluetooth";
      options = [
        "bind"
        "noauto"
        "x-systemd.automount"
      ];
      noCheck = true;
    };    

    # Ensure SSH keys are available for agenix to decrypt during stage-2-init.
    "/persist".neededForBoot = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
