{
  nix = {
    # Enable flakes.
    extraOptions = ''
      experimental-features = nix-command flakes dynamic-derivations recursive-nix ca-derivations
    '';
  };
}
