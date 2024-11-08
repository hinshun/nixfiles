{ config, pkgs, nixosModules, secrets, ... }:

let
  high_security = {
    mode = "0500";
    owner = "root";
  };

  user_readable = {
    mode = "0500";
    owner = "hinshun";
  };

in {
  imports = with nixosModules; [
    agenix
  ];

  environment.systemPackages = with pkgs; [
    agenix
  ];

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';

  age.secrets = {
    anthropic-api = {
      file = "${secrets}/anthropic-api.age";
    } // user_readable;

    hetzner-cloud = {
      file = "${secrets}/hetzner-cloud.age";
    } // user_readable;

    openai-api = {
      file = "${secrets}/openai-api.age";
    } // user_readable;

    openrouter-api = {
      file = "${secrets}/openrouter-api.age";
    } // user_readable;

    nix-access-tokens = {
      file = "${secrets}/nix-access-tokens.age";
    } // high_security;
  };
}
