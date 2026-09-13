#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="novyra-linux-arm64"
iso_label="NOVYRA_ARM_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="novyra <https://github.com/cstacks/novyra>"
iso_application="novyra linux arm64 live"
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