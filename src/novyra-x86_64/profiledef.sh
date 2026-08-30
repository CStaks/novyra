#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="novyra-linux"
iso_label="NOVYRA_$(date +%Y%m)"
iso_publisher="Novyra <https://github.com/cstacks/novyra>"
iso_application="Novyra Linux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlzma,109' -E 'ztailpacking')
bootstrap_tarball_compression=(xz -9e)
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/skel"]="0:0:755"
  ["/root"]="0:0:750"
)