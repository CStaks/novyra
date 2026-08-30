#!/usr/bin/env bash
set -euo pipefail

package_dir=${1:-packages}
repo_dir=${2:-repo/x86_64}
repo_name=${REPO_NAME:-novyra}

command -v repo-add >/dev/null || { echo "repo-add is required" >&2; exit 1; }
mkdir -p "$repo_dir"
shopt -s nullglob
packages=("$package_dir"/*.pkg.tar.zst)
((${#packages[@]} > 0)) || { echo "No packages found in $package_dir" >&2; exit 1; }

repo_add_args=()
if [[ -n "${GPG_KEY_ID:-}" ]]; then
  command -v gpg >/dev/null || { echo "gpg is required when GPG_KEY_ID is set" >&2; exit 1; }
  repo_add_args+=(--key "$GPG_KEY_ID")
fi

rm -f "$repo_dir/$repo_name.db.tar.gz" "$repo_dir/$repo_name.files.tar.gz"
repo-add "${repo_add_args[@]}" "$repo_dir/$repo_name.db.tar.gz" "${packages[@]}"
cp -f "$repo_dir/$repo_name.db.tar.gz" "$repo_dir/$repo_name.db"
if [[ -f "$repo_dir/$repo_name.files.tar.gz" ]]; then
  cp -f "$repo_dir/$repo_name.files.tar.gz" "$repo_dir/$repo_name.files"
fi
