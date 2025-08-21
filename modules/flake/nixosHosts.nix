{ self
, config
, inputs
, lib
, profiles
, withSystem
, ...
}:
let
  inherit (self)
    homeModules
    nixosModules
    palettes
  ;

  inherit (lib)
    mkOption
    types
  ;

  mkHost = { system, module }:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);

      nixosBase = {
        _module.args = {
          inherit profiles;
          pkgs = lib.mkForce pkgs;
        };
      };

      homeManagerBase = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = {
            inherit homeModules palettes;
          };
        };
      };

    in lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self nixosModules;
        inherit (inputs) secrets;
      };
      modules = [
        nixosBase
        nixosModules.home-manager
        homeManagerBase
        module
      ];
    };

  hostsFor = system:
    lib.mapAttrs
      (_: module: mkHost { inherit system module; })
      config.nixosHosts;

  nixosConfigurations = hostsFor "x86_64-linux";

  buildNixOSFor = system:
    lib.mapAttrs'
      (name: nixosConfig: {
        name = "build-${name}";
        value = nixosConfig.config.system.build.toplevel;
      })
      (hostsFor system);

  diskoInstallerFor = toplevel: { config, lib, pkgs, ... }:
    let 
      disko-script =
        pkgs.writeShellScriptBin
          "disko"
          "${config.system.build.diskoScript}";

      disko-mount =
        pkgs.writeShellScriptBin
          "disko-mount"
          "${config.system.build.mountScript}";

      disko-format =
        pkgs.writeShellScriptBin
          "disko-format"
          "${config.system.build.formatScript}";

      install-system = pkgs.writeShellScriptBin "install-system" ''
        set -euo pipefail

        echo "Formatting disks..."
        . ${disko-format}/bin/disko-format

        echo "Mounting disks..."
        . ${disko-mount}/bin/disko-mount

        echo "Installing system..."
        nixos-install --system ${toplevel}

        echo "Done!"
      '';

    in {
      # Don't generate filesystems on ISO image.
      disko.enableConfig = lib.mkDefault false;

      environment.systemPackages = [
        disko-script
        disko-mount
        disko-format
        install-system
      ];
    };

  mkISO = { system, nixosConfig, modules ? [] }:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);

      inherit (nixosConfig.config.system.build) toplevel;

    in inputs.nixos-generators.nixosGenerate {
      inherit pkgs;

      format = "install-iso";

      specialArgs = {
        inherit (inputs) secrets;
      };

      modules = with nixosModules; [
        disko
        iso
        (diskoInstallerFor toplevel)
      ] ++ modules;
    };

  flashScript = system: iso-image:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);

    in pkgs.writeShellApplication {
      name = "flash-iso";
      runtimeInputs = with pkgs; [
        pv
        gum
      ];

      text = ''
        set -euo pipefail

        # Confirm device.
        iso="$(find ${iso-image}/iso -mindepth 1 | pv)"
        dev="/dev/$(lsblk -d -n --output RM,NAME,SIZE,TYPE,VENDOR | awk '{ if ($1 != 0) { print } }' | gum choose --header "Select device to flash" | awk '{print $2}')"

        # Format the disk.
        pv -tpreb "$iso" | sudo dd bs=4M of="$dev" iflag=fullblock conv=notrunc,noerror oflag=sync
      '';
    };

  flashNixOSFor = { system, nixosConfig, modules ? [] }:
    let iso-image = mkISO { inherit system nixosConfig modules; };
    in {
      type = "app";
      program = "${flashScript system iso-image}/bin/flash-iso";
    };

in {
  options.nixosHosts = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
  };

  config = {
    flake = { inherit nixosConfigurations; };

    perSystem = { system, ... }: {
      packages = buildNixOSFor system;

      apps.flash-framework = flashNixOSFor {
        system = "x86_64-linux";
        nixosConfig = nixosConfigurations.framework;
        modules = with nixosModules; [
          disko-zfs-impermanence
          { disko.devices.disk.main.device = "/dev/nvme0n1"; }
        ];
      };
    };
  };
}
