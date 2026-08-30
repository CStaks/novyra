#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-arm64-hyprland"
iso_label="ARCH_ARM_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Arch Linux ARM <https://archlinuxarm.org>"
iso_application="Arch Linux ARM Hyprland Live"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi-aarch64.grub.esp'
           'uefi-aarch64.grub.eltorito')
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlzma,109' -E 'ztailpacking')
bootstrap_tarball_compression=(xz -9e)
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/skel"]="0:0:755"
  ["/root"]="0:0:750"
)