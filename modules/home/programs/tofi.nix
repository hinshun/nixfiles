{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tofi;

  iniFile = pkgs.writeText "config" (
    lib.generators.toINIWithGlobalSection {} {
      globalSection = cfg.settings;
    }
  );

in {
  options.programs.tofi = {
    enable = mkEnableOption "tofi";

    package = mkOption {
      type = types.package;
      default = pkgs.tofi;
      defaultText = literalExpression "pkgs.tofi";
      description = "Package providing <command>tofi</command>.";
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Configuration to use for tofi. See
        <link xlink:href="https://github.com/philj56/tofi/blob/master/doc/tofi.5.md"/>
        for available options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = mkIf (cfg.settings != { }) {
      "tofi/config".source = iniFile;
    };
  };
}
