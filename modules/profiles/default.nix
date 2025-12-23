let
  hinshun = ./hinshun/home.nix;

in {
  _module.args.profiles = {
    inherit hinshun;
  };
}
