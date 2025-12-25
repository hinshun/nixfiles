{ inputs, config, ... }:
{
  config.perSystem = { pkgs, system, ... }:
    let
      tf-config = inputs.terranix.lib.terranixConfiguration {
        inherit system pkgs;
        extraArgs = {
          inherit (config.flake) nixosConfigurations;
        };
        modules = [
          ./terranix/options
          ./terranix/init.nix
          ./terranix/servers.nix
        ];
      };

    in {
      packages.tf-config = tf-config;

      apps = {
        plan = {
          type = "app";
          program = toString (pkgs.writers.writeBash "plan" ''
            tmpdir=$(mktemp -d)
            trap "rm -rf $tmpdir" EXIT
            ln -s ${tf-config} "$tmpdir/config.tf.json"
            export TF_DATA_DIR="$PWD/.terraform"
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" init -input=false
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" plan
          '');
        };

        apply = {
          type = "app";
          program = toString (pkgs.writers.writeBash "apply" ''
            tmpdir=$(mktemp -d)
            trap "rm -rf $tmpdir" EXIT
            ln -s ${tf-config} "$tmpdir/config.tf.json"
            export TF_DATA_DIR="$PWD/.terraform"
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" init -input=false
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" apply
          '');
        };

        destroy = {
          type = "app";
          program = toString (pkgs.writers.writeBash "destroy" ''
            tmpdir=$(mktemp -d)
            trap "rm -rf $tmpdir" EXIT
            ln -s ${tf-config} "$tmpdir/config.tf.json"
            export TF_DATA_DIR="$PWD/.terraform"
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" init -input=false
            ${pkgs.opentofu}/bin/tofu -chdir="$tmpdir" destroy
          '');
        };
      };
    };
}

