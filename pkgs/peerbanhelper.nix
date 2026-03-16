{
  lib,
  stdenv,
  pkgs,
  makeWrapper,
  jdk25_headless,
  ...
}:

stdenv.mkDerivation rec {
  pname = "peerbanhelper";
  version = "9.3.9";

  src = pkgs.fetchzip {
    url = "https://github.com/PBH-BTN/PeerBanHelper/releases/download/v${version}/PeerBanHelper_${version}.zip";
    hash = "sha256-ieZxZVrzbY2YckapKDWD5YNFjygibEabG+v4nVbCZvI=";
  };

  nativeBuildInputs = [
    makeWrapper
    jdk25_headless
  ];

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk25_headless}/bin/java $out/bin/${pname} \
        --add-flags "-cp $src/libraries -jar $src/PeerBanHelper.jar"
  '';

  meta = with lib; {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules.";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
    mainProgram = pname;
  };
}
