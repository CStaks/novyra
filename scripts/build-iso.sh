#!/usr/bin/env bash
set -euo pipefail

variant=${1:-standard}
out_dir=${2:-out}
release_channel=${RELEASE_CHANNEL:-nightly}
release_version=${RELEASE_VERSION:-$(git -C "$(dirname "${BASH_SOURCE[0]}")/.." rev-parse --short=7 HEAD)}
profile_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../iso" && pwd)"

case "$variant" in
  standard|nvidia) ;;
  *) echo "Usage: $0 {standard|nvidia} [output-directory]" >&2; exit 2 ;;
esac

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
cp -a "$profile_dir/." "$work_dir/"

if [[ "$variant" == "nvidia" ]]; then
  printf '%s\n' nvidia nvidia-utils >> "$work_dir/packages.x86_64"
  sed -i 's/^modules=().*/modules=(nvidia nvidia_modeset nvidia_drm nvidia_uvm)/' "$work_dir/profiledef.sh"
fi

mkdir -p "$out_dir"
archiso -v -w "$work_dir/work" -o "$out_dir" "$work_dir"

shopt -s nullglob
for iso in "$out_dir"/*.iso; do
  base=$(basename "$iso" .iso)
  suffix=
  [[ "$variant" == "nvidia" ]] && suffix=-nvidia
  mv "$iso" "$out_dir/arch-custom-${release_channel}-${release_version}${suffix}.iso"
done
