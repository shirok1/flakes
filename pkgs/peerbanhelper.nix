{
  lib,
  stdenv,
  pkgs,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  pname = "peerbanhelper";
  version = "9.3.10";

  src = pkgs.fetchFromGitHub {
    owner = "PBH-BTN";
    repo = "PeerBanHelper";
    rev = "v${version}";
    hash = "sha256-8QakLztjyIhPfdaPAcL/+ZNzcir4LSzYTwrG8e8IpE8=";
  };

  nativeBuildInputs = [
    pkgs.gradle
    pkgs.makeWrapper
    pkgs.nodejs
    pkgs.pnpm_9
    pkgs.pnpmConfigHook
  ];

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pname version src;
    hash = "sha256-1JQBxJ4UcjXssNTC8veoFqgLpE+R4kRv4wCfewn899E=";
    sourceRoot = "${src.name}/webui";
    fetcherVersion = 1;
  };

  pnpmRoot = "webui";
  prePnpmInstall = "pnpm install --no-frozen-lockfile";

  mitmCache = pkgs.gradle.fetchDeps {
    pkg = pkgs.stdenv.mkDerivation {
      name = "dummy";
      src = src;
      nativeBuildInputs = [ pkgs.gradle pkgs.makeWrapper pkgs.nodejs pkgs.pnpm_9 pkgs.pnpmConfigHook ];
      pnpmDeps = pnpmDeps;
      pnpmRoot = pnpmRoot;
      prePnpmInstall = prePnpmInstall;
    };
    data = ./deps.json;
  };

  buildPhase = ''
    runHook preBuild

    # build webui
    cd webui
    pnpm run build
    cd ..

    # copy webui dist to resources
    mkdir -p src/main/resources/static
    cp -r webui/dist/* src/main/resources/static/

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
