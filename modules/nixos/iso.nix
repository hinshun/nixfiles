{ lib, pkgs, secrets, ... }:

let
  inherit (lib) mapAttrs' nameValuePair mkForce;

in {
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    httpie
    diskrsync
    partclone
    ntfsprogs
    ntfs3g
  ];

  # Use vim as the default editor
  environment.variables.EDITOR = "vim";

  networking = {
    useNetworkd = true;
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    usePredictableInterfaceNames = false;
  };

  services.resolved.enable = false;

  systemd = {
    network.enable = true;
    network.networks =
      mapAttrs'
      (num: _:
        nameValuePair "eth${num}" {
          extraConfig = ''
            [Match]
            Name = eth${num}
            [Network]
            DHCP = both
            LLMNR = true
            IPv4LL = true
            LLDP = true
            IPv6AcceptRA = true
            IPv6Token = ::521a:c5ff:fefe:65d9
            # used to have a stable address for zfs send
            Address = fd42:4492:6a6d:43:1::${num}/64
            [DHCP]
            UseHostname = false
            RouteMetric = 512
          '';
        })
      {
        "0" = {};
        "1" = {};
        "2" = {};
        "3" = {};
      };
    services.update-prefetch.enable = false;
    services.sshd.wantedBy = mkForce ["multi-user.target"];
  };

  documentation = {
    enable = false;
    nixos.options.warningsAreErrors = false;
    info.enable = false;
  };

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    secrets.publicKeys.edgar
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
