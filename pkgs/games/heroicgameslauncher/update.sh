#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=../../../ -i bash -p wget yarn2nix

set -euo pipefail

if [ "$#" -ne 1 ] || [[ "$1" == -* ]]; then
  echo "Regenerates the Yarn dependency lock files for the heroicgameslauncher package."
  echo "Usage: $0 <git release tag>"
  exit 1
fi

HEROIC_SRC="https://raw.githubusercontent.com/Heroic-Games-Launcher/HeroicGamesLauncher/$1"

wget "$HEROIC_SRC/package.json" -O heroic-package.json
wget "$HEROIC_SRC/yarn.lock" -O heroic-yarndeps.lock
yarn2nix --lockfile=heroic-yarndeps.lock > heroic-yarndeps.nix
rm heroic-yarndeps.lock
