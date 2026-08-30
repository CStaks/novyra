#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run this setup with sudo."
  exit 1
fi

id greeter >/dev/null 2>&1 || { echo "greeter user is missing" >&2; exit 1; }

pacman -Sy --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-settings
systemctl enable --now NetworkManager

build_dir=$(mktemp -d /var/tmp/novyra-aur.XXXXXX)
cleanup() { rm -rf "$build_dir"; }
trap cleanup EXIT
chown -R greeter:greeter "$build_dir"

if ! command -v paru >/dev/null 2>&1; then
  sudo -u greeter git clone --depth=1 https://aur.archlinux.org/paru.git "$build_dir/paru"
  sudo -u greeter bash -c "cd '$build_dir/paru' && makepkg --syncdeps --install --noconfirm"
fi

sudo -u greeter paru -S --needed --noconfirm visual-studio-code-bin brave-bin zed lazyvim warehouse

install -d -m 755 /etc/flatpak/remotes.d
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if [[ ! -e /home/greeter/.config/nvim ]]; then
  install -d -o greeter -g greeter /home/greeter/.config
  sudo -u greeter git clone --depth=1 https://github.com/LazyVim/starter /home/greeter/.config/nvim
  rm -rf /home/greeter/.config/nvim/.git
fi
chown -R greeter:greeter /home/greeter/.config

echo "Application setup complete. Re-login to refresh desktop entries."
