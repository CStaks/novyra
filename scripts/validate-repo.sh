#!/usr/bin/env bash
set -euo pipefail

required=(
  iso/profiledef.sh
  iso/packages.x86_64
  iso/airootfs/etc/greetd/config.toml
  iso/airootfs/etc/systemd/system/greetd.service
  iso/airootfs/usr/local/bin/novyra-install
  iso/airootfs/usr/local/share/novyra/install-novyra.sh
)
for file in "${required[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required file: $file" >&2; exit 1; }
done
bash -n scripts/build-iso.sh scripts/install-novyra.sh scripts/build-package-repo.sh
bash -n iso/profiledef.sh iso/airootfs/usr/local/bin/novyra-install iso/airootfs/usr/local/share/novyra/install-novyra.sh
printf 'novyra repository validation passed.\n'
