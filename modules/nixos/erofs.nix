{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [{
      name = "erofs-over-fscache";
      patch = null;
      extraConfig = ''
        FSCACHE m
        CACHEFILES m
        CACHEFILES_ONDEMAND y
        EROFS_FS m
        EROFS_FS_ONDEMAND y
      '';
    }];
  };

  environment.systemPackages = with pkgs; [
    erofs-utils
  ];
}
