{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_22,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  writeShellApplication
}:

let
  subStoreVersion = "2.20.58";
  frontEndVersion = "2.15.85";

  backendSrc = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store";
    rev = subStoreVersion;
    hash = "sha256-gnr2oJ955yvzgVLJY9VrD0bm+jzBX6bLUWYIuQudly4=";
  };

  frontendSrc = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store-Front-End";
    rev = frontEndVersion;
    hash = "sha256-IimSK1p9UWr6DrzEP1seG/y1vj0rl8FpCJB5P/u9mOo=";
  };

  # Use fetchPnpmDeps since it is the standard for packaging pnpm derivations
  backend = stdenv.mkDerivation (finalAttrs: {
    pname = "sub-store-backend";
    version = subStoreVersion;

    src = backendSrc;

    nativeBuildInputs = [
      nodejs_22
      pnpm_9
      (pnpmConfigHook.override { pnpm = pnpm_9; })
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_9;
      fetcherVersion = 3;
      hash = "sha256-FeEIyApuBzIW0SYEQBueDkSqdu50smqTEzjSndJ5l00=";
    };

    buildPhase = ''
      runHook preBuild

      # The build script expects to write to dist/
      pnpm run bundle:esbuild

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r dist/sub-store.bundle.js $out/lib/

      runHook postInstall
    '';
  });

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "sub-store-frontend";
    version = frontEndVersion;

    src = frontendSrc;

    nativeBuildInputs = [
      nodejs_22
      pnpm_9
      (pnpmConfigHook.override { pnpm = pnpm_9; })
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_9;
      fetcherVersion = 3;
      hash = "sha256-uTiTAeVoFQMuw21/8JS0XyrWX85SXTypMDfqFjgK+hQ=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out/

      runHook postInstall
    '';
  });

in
writeShellApplication {
  name = "sub-store";

  text = ''
    DATA_DIR="''${SUB_STORE_DATA_DIR:-''${STATE_DIR:-/var/lib/sub-store}}"

    mkdir -p "$DATA_DIR"
    cd "$DATA_DIR"

    export SUB_STORE_DOCKER=true
    export SUB_STORE_FRONTEND_PATH="${frontend}"
    export SUB_STORE_DATA_BASE_PATH="$DATA_DIR"

    exec ${nodejs_22}/bin/node "${backend}/lib/sub-store.bundle.js"
  '';

  meta = with lib; {
    description = "Sub-Store bundle (node) + front-end dist, with clean wrapper";
    platforms = platforms.linux;
    mainProgram = "sub-store";
    license = licenses.agpl3Only;
  };
}
