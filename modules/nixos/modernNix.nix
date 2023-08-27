{
  nix = {
    # Enable flakes.
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
