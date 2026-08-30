#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then echo "Run this installer with sudo."; exit 1; fi
if [[ ! -d /sys/firmware/efi ]]; then echo "This installer requires UEFI mode."; exit 1; fi

lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
read -r -p "Target disk (ALL DATA WILL BE ERASED): " disk
[[ -b "$disk" ]] || { echo "Not a block device: $disk" >&2; exit 1; }
read -r -p "Type ERASE to continue: " confirmation
[[ "$confirmation" == ERASE ]] || { echo "Cancelled."; exit 1; }

mount_dir=/mnt
umount -R "$mount_dir" 2>/dev/null || true
wipefs -a "$disk"
parted -s "$disk" mklabel gpt
parted -s "$disk" mkpart ESP fat32 1MiB 1GiB
parted -s "$disk" set 1 esp on
parted -s "$disk" mkpart root ext4 1GiB 100%
partprobe "$disk"
case "$disk" in *nvme*|*mmcblk*) efi="${disk}p1"; root="${disk}p2";; *) efi="${disk}1"; root="${disk}2";; esac
mkfs.fat -F32 "$efi"
mkfs.ext4 -F "$root"
mount "$root" "$mount_dir"
mkdir -p "$mount_dir/boot"
mount "$efi" "$mount_dir/boot"

pacstrap -K "$mount_dir" base linux linux-firmware networkmanager hyprland greetd tuigreet ghostty polkit xdg-desktop-portal-hyprland sudo flatpak lazygit neovim git base-devel wget curl ca-certificates archlinux-keyring
fstabgen -U "$mount_dir" >> "$mount_dir/etc/fstab"
install -d -m 755 "$mount_dir/etc/pacman.conf.d" "$mount_dir/etc/pacman.d"
cat > "$mount_dir/etc/pacman.conf.d/cachyos.conf" <<'CACHYOS'
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
CACHYOS
cat > "$mount_dir/etc/pacman.d/cachyos-mirrorlist" <<'MIRROR'
Server = https://mirror.cachyos.org/repo/$arch/$repo
MIRROR
cat > "$mount_dir/etc/pacman.conf.d/novyra.conf" <<'NOVYRA'
[novyra]
SigLevel = Required DatabaseOptional
Server = https://sourceforge.net/projects/novyra/files/repo/$arch
NOVYRA
arch-chroot "$mount_dir" pacman-key --init
arch-chroot "$mount_dir" pacman -Sy --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-settings
arch-chroot "$mount_dir" systemctl enable NetworkManager greetd novyra-first-boot.service
arch-chroot "$mount_dir" bootctl install

cat > "$mount_dir/boot/loader/loader.conf" <<'LOADER'
default novyra
timeout 3
editor no
LOADER
root_uuid=$(blkid -s UUID -o value "$root")
cat > "$mount_dir/boot/loader/entries/novyra.conf" <<ENTRY
 title novyra
 linux /vmlinuz-linux
 initrd /initramfs-linux.img
 options root=UUID=$root_uuid rw
ENTRY

arch-chroot "$mount_dir" useradd -m -G wheel greeter 2>/dev/null || true
install -d -m 700 "$mount_dir/home/greeter/.config/hypr"
cat > "$mount_dir/home/greeter/.config/hypr/hyprland.conf" <<'HYPR'
monitor=,preferred,auto,1
$terminal = ghostty
bind = SUPER, Q, killactive,
bind = SUPER, RETURN, exec, $terminal
bind = SUPER, M, exit,
HYPR
chown -R 1000:1000 "$mount_dir/home/greeter"
sync
umount -R "$mount_dir"
echo "Installation complete. Reboot and remove the ISO."
