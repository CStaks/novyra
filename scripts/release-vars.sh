#!/usr/bin/env bash
set -euo pipefail

channel=${RELEASE_CHANNEL:-}
if [[ -z "$channel" ]]; then
  if [[ "${GITHUB_REF_TYPE:-}" == tag ]]; then
    channel=stable
  else
    channel=nightly
  fi
fi

case "$channel" in
  nightly)
    version=${RELEASE_VERSION:-$(git rev-parse --short=7 HEAD)}
    [[ "$version" =~ ^[0-9a-f]{7,40}$ ]] || { echo "Invalid nightly version: $version" >&2; exit 1; }
    ;;
  stable)
    version=${RELEASE_VERSION:-${GITHUB_REF_NAME:-}}
    [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Stable releases require a vMAJOR.MINOR.PATCH tag" >&2; exit 1; }
    ;;
  *) echo "Unsupported release channel: $channel" >&2; exit 1 ;;
esac

printf 'RELEASE_CHANNEL=%s\n' "$channel"
printf 'RELEASE_VERSION=%s\n' "$version"
printf 'ISO_STANDARD=arch-custom-%s-%s.iso\n' "$channel" "$version"
printf 'ISO_NVIDIA=arch-custom-%s-%s-nvidia.iso\n' "$channel" "$version"
printf 'SOURCEFORGE_PATH=%s/%s\n' "$channel" "$version"
