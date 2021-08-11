{ lib
, stdenv
, fetchFromGitHub
, copyDesktopItems
, makeWrapper
, makeDesktopItem
, mkYarnPackage
, electron

, useWayland ? false
}:

let
  version = "1.9.2";
  pname = "heroic";

  electron_exec = if stdenv.isDarwin then "${electron}/Applications/Electron.app/Contents/MacOS/Electron" else "${electron}/bin/electron";
in
mkYarnPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Heroic-Games-Launcher";
    repo = "HeroicGamesLauncher";
    rev = "v${version}";
    sha256 = "sha256-6eDhcool6KZaVH9kUS9ecG1aMzg62VqnZo1xWL+CIhI=";
  };

  packageJSON = ./heroic-package.json;
  yarnNix = ./heroic-yarndeps.nix;

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    pushd deps/heroic/
    npx tsc
    yarn run i18n
    popd

    runHook postBuild
  '';

  installPhase = ''
    # resources
    mkdir -p "$out/share/heroic"
    mkdir -p "$out/share/icons/hicolor/512x512/apps"
    cp -r './deps/heroic' "$out/share/heroic/electron"
    cp -r './deps/heroic/public/icon.png' "$out/share/icons/hicolor/512x512/apps/heroic.png"
    rm "$out/share/heroic/electron/node_modules"
    cp -r './node_modules' "$out/share/heroic/electron"

    # icons
    #for icon in $out/share/heroic/electron/build/icons/*.png; do
    #  mkdir -p "$out/share/icons/hicolor/$(basename $icon .png)/apps"
    #  ln -s "$icon" "$out/share/icons/hicolor/$(basename $icon .png)/apps/heroic.png"
    #done

    # executable wrapper
    makeWrapper '${electron_exec}' "$out/bin/${pname}" \
      --add-flags "$out/share/heroic/electron${lib.optionalString useWayland " --enable-features=UseOzonePlatform --ozone-platform=wayland"}"
  '';

  dontDist = true;

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${pname} %u";
    icon = pname;
    desktopName = "Heroic Games Launcher";
    categories = "Game;";
  };

  meta = with lib; {
    description = "A Native GUI Epic Games Launcher for Linux, Windows and Mac";
    homepage = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ fufexan ];
    platforms = platforms.unix;
  };
}
