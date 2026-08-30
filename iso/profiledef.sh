#!/usr/bin/env bash

iso_name="novyra"
iso_label="NOVYRA_$(date +%Y%m)"
iso_publisher="Novyra"
iso_application="Novyra live environment"
iso_version="$(date +%Y.%m.%d)"
install_dir="novyra"
bootmodes=('bios.syslinux' 'uefi-x64.systemd-boot')
arch="x86_64"
work_dir="work"
out_dir="out"

# The NVIDIA build script replaces this value with the NVIDIA modules.
modules=()

buildmodes=('iso')
