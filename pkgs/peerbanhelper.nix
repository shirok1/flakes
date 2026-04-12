{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  makeWrapper,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  fetchPnpmDeps,
}:

let
  version = "9.3.10";
  src = fetchFromGitHub {
    owner = "PBH-BTN";
    repo = "PeerBanHelper";
    rev = "v${version}";
    hash = "sha256-8QakLztjyIhPfdaPAcL/+ZNzcir4LSzYTwrG8e8IpE8=";
  };

  webui = stdenv.mkDerivation {
    pname = "peerbanhelper-webui";
    inherit version src;

    nativeBuildInputs = [
      nodejs
      pnpm_9
      pnpmConfigHook
    ];

    pnpmDeps = fetchPnpmDeps {
      pname = "peerbanhelper-webui";
      inherit version src;
      hash = "sha256-1JQBxJ4UcjXssNTC8veoFqgLpE+R4kRv4wCfewn899E=";
      sourceRoot = "${src.name}/webui";
      fetcherVersion = 1;
    };

    pnpmRoot = "webui";
    # Force npm config locally inside the derivation sandbox to ignore strict SSL
    prePnpmInstall = ''
      pnpm config set strict-ssl false
      npm config set strict-ssl false
    '';

    buildPhase = ''
      runHook preBuild
      cd webui
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "peerbanhelper";
  inherit version src;

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    pkg = stdenv.mkDerivation {
      name = "dummy";
      src = src;
      nativeBuildInputs = [ gradle makeWrapper ];
    };
    data = ./deps.json;
  };

  buildPhase = ''
    runHook preBuild

    # copy webui dist to resources
    mkdir -p src/main/resources/static
    cp -r ${webui}/* src/main/resources/static/

    # build jar
    gradle build -x test --no-daemon

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java/libraries
    cp build/libs/PeerBanHelper*.jar $out/share/java/PeerBanHelper.jar

    runHook postInstall
  '';

  meta = with lib; {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules.";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.fromSource ];
    mainProgram = pname;
  };
}
