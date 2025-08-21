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

  # Let Nix daemon use github access token to fetch private flakes.
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = {
    anthropic-api = {
      file = secrets.ageSecrets.anthropic-api;
    } // user_readable;

    hetzner-cloud = {
      file = secrets.ageSecrets.hetzner-cloud;
    } // user_readable;

    openai-api = {
      file = secrets.ageSecrets.openai-api;
    } // user_readable;

    openrouter-api = {
      file = secrets.ageSecrets.openrouter-api;
    } // user_readable;

    nix-access-tokens = {
      file = "/persist/etc/agenix/nix-access-tokens.age";
    } // user_readable;
  };
}
