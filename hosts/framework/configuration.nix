{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    # Configure to use nixbuild.net.
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];

    # Enable flakes.
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    nixPath =
      [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixos-config=/persist/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # source: https://grahamc.com/blog/erase-your-darlings
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  # source: https://grahamc.com/blog/nixos-on-zfs
  boot.kernelParams = [ "elevator=none" ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPatches = [{
  #   name = "erofs-over-fscache";
  #   patch = null;
  #   extraConfig = ''
  #     FSCACHE m
  #     CACHEFILES m
  #     CACHEFILES_ONDEMAND y
  #     EROFS_FS m
  #     EROFS_FS_ONDEMAND y
  #   '';
  # }];

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
        direnv
        discord
        erofs-utils
        firefox
        fzf
        gcc
        git
        go_1_18
        google-chrome
        htop
        (pkgs.callPackage ./kakoune.nix {})
        kazam
        pamixer
        psmisc
        ripgrep
        shadow
        vlc
        weechat
        xsel
        xxd
        zoom-us
      ];

    etc."NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/docker - - - - /persist/var/lib/docker"
  ];

  fileSystems."/var/lib/bluetooth" = {
    device = "/persist/var/lib/bluetooth";
    options = [
      "bind"
      "noauto"
      "x-systemd.automount"
    ];
    noCheck = true;
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

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
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

  virtualisation = {
    docker.enable = true;
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
	extraGroups =
	  [
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

  fonts.fonts = with pkgs; [
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
