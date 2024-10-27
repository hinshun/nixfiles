{ pkgs, nixosModules, profiles, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
  ] ++ (with nixosModules; [
    agenix
    darlings
    modernNix
    nixbuild
    wayland
    # containerd
    # nix-snapshotter
    # buildkitd
  ]);

  home-manager.users = { inherit (profiles) hinshun; };

  nix.settings = {
    trusted-users = [ "root" "hinshun" ];
    access-tokens = [ "github.com=${config.age.secrets.github-token.path}" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/New_York";
  # time.timeZone = "Asia/Hong_Kong";

  networking = {
    hostId = "633815e9";
    hostName = "framework";
    enableIPv6 = false;
    networkmanager.enable = true;
    firewall.allowedUDPPortRanges = [
      { from = 32768; to = 60999; }
    ];
  };

  environment = {
    pathsToLink = [ "/libexec" ];

    systemPackages = with pkgs; [
      alacritty
      arandr
      bat
      brightnessctl
      fzf
      hlb
      htop
      jq
      pamixer
      pinentry-curses
      psmisc
      ripgrep
      shadow
      tree
      xdg-utils
      xsel
      xxd
    ];
  };

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.fwupd.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  services.fstrim.enable = true;

  services.pcscd.enable = true;
  services.fprintd.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  # security.wrappers = {
  #   nerdctl = {
  #     setuid = true;
  #     owner = "root";
  #     group = "root";
  #     source = "${pkgs.nerdctl}/bin/nerdctl";
  #   };
  # };

  # virtualisation.containerd = {
  #   enable = true;
  #   nixSnapshotterIntegration = true;
  # };

  # services.nix-snapshotter = {
  #   enable = true;
  # };

  # services.buildkitd = {
  #   enable = true;
  # };

  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
    };
  };

  # services.xserver = {
  #   enable = true;
  #   libinput.enable = true;
  #   xkbOptions = "ctrl:nocaps";
  #   windowManager.i3 = {
  #     enable = true;
  #     extraPackages = with pkgs; [
  #       rofi
  #       polybar
  #     ];
  #   };
  #   displayManager.defaultSession = "none+i3";
  # };

  hardware.pulseaudio.enable = false;
  services.thermald.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
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
          "buildkitd"
          "containerd"
    	    "docker"
    	    "networkmanager"
    	    "wheel"
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

  age.identityPaths = [ "/home/hinshun/.config/sops/age/keys.txt" ];
}
