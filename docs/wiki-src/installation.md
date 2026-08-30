---
name: Installation
description: Build or obtain the Novyra ArchISO image, boot it, and install from the live environment.
---

# Installation

Novyra currently ships as an ArchISO profile. The repository contains the live image profile, but it does not yet include a graphical or automated disk installer. Treat this as a live environment and use the standard Arch installation workflow from the terminal.

## Requirements

- A 64-bit x86_64 machine or virtual machine
- At least 2 GiB RAM and 20 GiB of storage recommended
- A USB drive, if installing on physical hardware
- A backup of important data — installation can erase the target disk

## Get the image

Download a published ISO from the [Novyra repository](https://github.com/CStaks/novyra). If no release image is available yet, build one from the repository instead.

## Build the ISO from source

Builds are performed with `mkarchiso` inside an Arch Linux environment. The included GitHub Actions workflow uses a privileged `archlinux:latest` container.

```sh
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm archiso libisoburn squashfs-tools grub
mkdir -p work out
mkarchiso -v -w work/ -o out/ ./src/novyra/
```

The resulting ISO is written to `out/`. The profile supports BIOS via Syslinux and UEFI via GRUB.

## Write the ISO to a USB

Replace `/dev/sdX` with the whole USB device, not a partition. This erases the USB drive.

```sh
dd if=out/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

On a virtual machine, attach the ISO directly instead of writing it to USB.

## Boot the live environment

1. Boot the target machine from the Novyra USB or ISO.
2. Choose the default boot entry.
3. Confirm that networking works.
4. Identify the target disk with `lsblk`.

The current profile includes the base system, Linux kernel, OpenSSH, QEMU guest agent, VirtualBox guest utilities, Hyper-V support, and VMware tools. It does not currently define a desktop session or installer configuration in the repository.

## Install to disk

Use the standard Arch Linux installation process from the live shell:

1. Set the correct keyboard layout with `loadkeys` if needed.
2. Verify network access and synchronize the clock.
3. Partition and format the target disk.
4. Mount the target filesystem under `/mnt`.
5. Install the base system and kernel with `pacstrap`.
6. Generate `/etc/fstab` with `genfstab`.
7. Enter the new system with `arch-chroot`.
8. Configure timezone, locale, hostname, users, networking, and a bootloader.
9. Enable any required guest-agent or SSH services.
10. Exit, unmount `/mnt`, reboot, and remove the installation media.

Consult the [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide) for the authoritative commands and hardware-specific details.

## After installation

Update the installed system and configure your preferred desktop or window manager. Hyprland and CachyOS repository integration are planned product direction, but they are not present in the current ISO profile files yet.
