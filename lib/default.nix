{ lib }:
{
  readModules = path:
    let
      nixFiles =
        lib.filterAttrs
          (filename: type:
            type == "regular" &&
              filename != "default.nix" &&
              lib.hasSuffix ".nix" filename
          )
          (builtins.readDir path);

      nixosModules =
        lib.mapAttrs'
          (filename: _:
            lib.nameValuePair
              (lib.removeSuffix ".nix" filename)
              (import "${path}/${filename}")
          )
          nixFiles;

    in nixosModules;
}
