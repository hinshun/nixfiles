{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.aider;
in {
  options.programs.aider = {
    enable = mkEnableOption "aider-chat";

    package = mkOption {
      type = types.package;
      default = pkgs.aider;
      defaultText = literalExpression "pkgs.aider";
      description = "The aider package to use.";
    };

    # Add more options here as needed
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Add more configuration here as needed
  };
}
