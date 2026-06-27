{
  lib,
  stdenv,
  fetchzip,
  fetchFromGitHub,
  buildFHSEnv,
  writeShellScript,
  buildNpmPackage,
  nodejs,
  makeWrapper,
}:

let
  pname = "asphyxia";
  version = "v1.60b";
in
buildNpmPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "asphyxia-core";
    repo = "core";
    rev = version;
    sha256 = "sha256-bRgMLvyPF5fIr2NaruwB+oY2ItZ7Ulo0muFj9BH3j38=";
  };

  npmDepsHash = "sha256-/wFg4fZL2CBO/XKHbsat28Bk1IzlPtFta2sJlShw89U=";

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  postPatch = ''
    substituteInPlace src/utils/EamuseIO.ts \
      --replace-fail \
      "export const ASSETS_PATH = path.join(pkg ? __dirname : \`../build-env\`, 'assets');" \
      "export const ASSETS_PATH = path.join('$out/share/asphyxia', 'assets');"
  '';

  buildPhase = ''
    runHook preBuild

    npx --no-install tsc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/asphyxia
    mkdir -p $out/share/asphyxia

    cp -r dist package.json node_modules plugins $out/lib/asphyxia/
    cp -r build-env/assets $out/share/asphyxia/

    makeWrapper ${nodejs}/bin/node $out/bin/asphyxia \
      --add-flags "$out/lib/asphyxia/dist/AsphyxiaCore.js"

    runHook postInstall
  '';

  pluginSrc = fetchFromGitHub {
    owner = "asphyxia-core";
    repo = "plugins";
    # tracing "stable" branch
    rev = "997d141b3ba2ca7eb6806490ab2926cce48863c5";
    sha256 = "sha256-xxhnwIC8Ik0Wq3ccKtxXvYXSNfx5zoianoFDOGfGo1c=";
  };

  enabledPlugins = [
    "bst"
    "ddr"
    "gitadora"
    "iidx"
    "jubeat"
    "mga"
    "museca"
    "nostalgia"
    "popn"
    "popn-hello"
    "sdvx"
  ];

  plugins = stdenv.mkDerivation {
    inherit src pluginSrc;
    name = "asphyxia-plugins";

    installPhase = ''
      mkdir -p $out

      cp $src/plugins/asphyxia-core.d.ts $out/
      cp $src/plugins/package.json $out/
      cp $src/plugins/tsconfig.json $out/
    ''
    + lib.concatMapStringsSep "\n" (p: "cp -r ${pluginSrc}/${p}@asphyxia $out/") enabledPlugins;
  };

  meta = with lib; {
    description = "This is a “e-amuse emulator”";
    homepage = "https://asphyxia-core.github.io/";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = pname;
  };
}
