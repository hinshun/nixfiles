{
  gnutar,
  jre_headless,
  lib,
  makeWrapper,
  mcman,
  pv,
  stdenv,
}:

{
  name,
  src,
  outputHashAlgo ? "sha256",
  outputHashMode ? "recursive",
  outputHash,
}:

let
  deps = stdenv.mkDerivation {
    name = "${name}-build";
    inherit src
      outputHashAlgo
      outputHashMode
      outputHash
    ;

    buildInputs = [
      mcman
      jre_headless
    ];

    configurePhase = ''
    '';

    buildPhase = ''
      export HOME=$TMPDIR
      export CI=true
      export MCMAN_USE_CURSEFORGE=1
      export CURSEFORGE_API_KEY='$2a$10$bL4bIL5pUWqfcO7KQtnMReakwtfHbNKh6v1uTpKlzhwoueEJQnPnm'

      cd $src
      mcman build -o $out

      # Forge introduces self-references in log files.
      rm -vf $out/{,.}*.log
    '';

    dontPatchShebangs = true;
  };

in stdenv.mkDerivation rec {
  inherit name src;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    gnutar
    jre_headless
    pv
  ];

  buildPhase = ''
    # Build layout: symlink jars/oggs, copy configs with 755
    mkdir -p server
    cd server

    # Create directory structure (excluding libraries/mods which will be symlinked)
    find ${deps} -mindepth 1 -type d ! -path "*/libraries/*" ! -path "*/mods/*" ! -name libraries ! -name mods -printf '%P\0' | xargs -0 -I{} mkdir -p "{}"

    # Symlink libraries and mods wholesale
    ln -s ${deps}/libraries ${deps}/mods . 2>/dev/null || true

    # Copy config files with 644
    find ${deps} -type f \( -name "*.toml" -o -name "*.json" \) ! -path "*/libraries/*" ! -path "*/mods/*" -printf '%P\0' | \
      xargs -0 -I{} sh -c 'install -m 644 "${deps}/{}" "{}"'

    # Symlink everything else
    find ${deps} -type f ! \( -name "*.toml" -o -name "*.json" \) ! -path "*/libraries/*" ! -path "*/mods/*" -printf '%P\0' | \
      xargs -0 -I{} ln -s "${deps}/{}" "{}"

    cd ..
    tar -cf server.tar -C server .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/${name}
    cp server.tar $out/share/${name}/

    cat > $out/bin/minecraft-server <<EOF
    #!/usr/bin/env bash
    set -euo pipefail

    HASH_FILE=".nix-hash"
    CURRENT_HASH="$out"

    if [ -f "\$HASH_FILE" ] && [ "\$(cat "\$HASH_FILE")" = "\$CURRENT_HASH" ]; then
      echo "Server files up to date, skipping extraction."
    else
      echo "Extracting server files..."
      pv -f -n $out/share/${name}/server.tar | tar -xf -
      echo "\$CURRENT_HASH" > "\$HASH_FILE"
      echo "Extraction complete."
    fi

    echo "Starting server..."
    exec ./start.sh
    EOF

    chmod +x $out/bin/minecraft-server

    wrapProgram $out/bin/minecraft-server \
      --prefix PATH : ${lib.makeBinPath buildInputs}
  '';

  passthru = { inherit deps; };
}
