{
  lib,
  stdenv,
  pkgs,
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
    pkgs.autoPatchelfHook
    pkgs.zip
    pkgs.unzip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = [ "*" ];

  installPhase = ''
    mkdir -p $out/share/java/libraries

    install -Dm644 $src/libraries/* $out/share/java/libraries
    install -Dm644 $src/PeerBanHelper.jar $out/share/java
  '';

  preFixup = ''
    find $out/share/java -name "*.jar" -print0 | while IFS= read -r -d $'\0' jar; do
      if unzip -l "$jar" | grep -q '\.so$'; then
        echo "Patching $jar"
        dir=$(mktemp -d)
        unzip -q "$jar" -d "$dir"
        autoPatchelf "$dir"
        (cd "$dir" && zip -q -0 -r "$jar" .)
        rm -rf "$dir"
      fi
    done
  '';

  meta = with lib; {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules.";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
    mainProgram = pname;
  };
}
