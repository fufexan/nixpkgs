{
  lib,
  rustPlatform,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  blueprint-compiler,
  desktop-file-utils,
  libxml2,
  dbus,
  gtk4,
  libadwaita,
}:
rustPlatform.buildRustPackage rec {
  pname = "overskride";
  version = "unstable-2023-10-19";

  src = fetchFromGitHub {
    repo = "overskride";
    owner = "kaii-lb";
    rev = "ad75079864248005aebe8d131c870dfaed00c50e";
    hash = "sha256-5zsdxN9V0EoU0oZHNpx92gp6qF7cfUQt0CMxamyKQY0=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    gtk4
    libadwaita
  ];

  buildPhase = ''
    runHook preBuild

    meson setup build --prefix $out && cd build
    meson compile && meson devenv

    runHook postBuild
  '';

  meta = {
    description = "A simple yet powerful bluetooth client";
    homepage = "https://github.com/kaii-lb/overskride";
    changelog = "https://github.com/kaii-lb/overskride/blob/main/CHANGELOG.md";
    maintainers = with lib.maintainers; [fufexan];
    platforms = lib.platforms.linux;
  };
}
