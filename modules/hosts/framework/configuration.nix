{ pkgs, nixosModules, profiles, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ] ++ (with nixosModules; [
    darlings
    modernNix
    nixbuild
    nix-snapshotter
  ]);

  home-manager.users = { inherit (profiles) hinshun; };

  services.nix-snapshotter.rootless.enable = true;

  environment.sessionVariables = {
    CONTAINERD_SNAPSHOTTER = "nix";
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Los_Angeles";
  # time.timeZone = "Asia/Hong_Kong";

  networking.hostId = "633815e9";
  networking.hostName = "framework";
  networking.networkmanager.enable = true;

  environment = {
    pathsToLink = [ "/libexec" ];

    systemPackages = with pkgs;
      [
        alacritty
        arandr
        bazel_6
        erofs-utils
        gcc
        nerdctl
        pamixer
        (pkgs.callPackage ./kakoune.nix {})
        psmisc
        ripgrep
        shadow
        tree
        xsel
        xxd
      ];
  };

  programs.zsh.enable = true;

  programs.ssh = {
    startAgent = true;

    extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        IdentityFile /persist/etc/ssh/ssh_host_ed25519_key
    '';

    knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    xkbOptions = "ctrl:nocaps";
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        polybar
      ];
    };
    displayManager.defaultSession = "none+i3";
  };

  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        initialHashedPassword = "\$6\$iAk5.37C6RP0/eWn\$iaWSIognqRcFQ/CyoPGJmMC/jMujKwEAuKC55WYTA2WpnahREEgQpapKtltppoohZY1TaUeIs7Wob4bSNg8pg.";
      };
      hinshun = {
        isNormalUser = true;
        createHome = true;
        initialHashedPassword = "\$6\$RFQgR6OLNzEzzTMa\$gdYpa.d1hJhBK7awTnQA9.lb2nlVmzFyH8BxBlSd6o69IuAWBtzuF3irWJcfKuU/GGsJMjr0hBMDOVHOBwap7/";
      	extraGroups = [
    	    "wheel"
    	    "networkmanager"
    	    "docker"
    	  ];
      	group = "users";
      	uid = 1000;
      	home = "/home/hinshun";
      	shell = pkgs.zsh;

      	subUidRanges = [
      	  { startUid = 100000; count = 65536; }
      	];
      	subGidRanges = [
      	  { startGid = 100000; count = 65536; }
      	];
      };
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
      ];
    })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
