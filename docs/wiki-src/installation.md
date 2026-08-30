---
name: Installation
description: Download or build the novyra ISO, boot it, and install novyra to your disk with the built-in installer.
---

# Installation

novyra ships as a bootable Arch-based ISO. Boot it, connect to the network, and run the built-in installer from the live desktop or a terminal. The installer is a straightforward terminal flow — no manual partitioning required.

## Requirements

- A 64-bit x86_64 machine or virtual machine
- At least 4 GiB RAM and 20 GiB of storage recommended
- A USB drive (4 GiB or larger) if installing on physical hardware
- A backup of important data — **installation erases the target disk**

## Download the ISO

novyra ISOs are published on SourceForge and linked from GitHub Releases:

- **Nightly**: built daily from the latest Arch base, versioned by short commit hash.
- **Stable**: built only when a `vMAJOR.MINOR.PATCH` tag is pushed, using a pinned Arch image.

Both channels ship a standard variant and an NVIDIA variant (with NVIDIA drivers and kernel modules preconfigured).

Grab the latest links from the [GitHub Releases page](https://github.com/CStaks/novyra/releases) or the project page at [sourceforge.net/p/novyra](https://sourceforge.net/p/novyra/).

## Write the ISO to a USB

Replace `/dev/sdX` with the whole USB device, not a partition. This erases the USB drive.

```sh
dd if=novyra-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

On a virtual machine, attach the ISO directly instead of writing it to USB.

## Boot the live environment

1. Boot the target machine from the USB stick (UEFI mode is required by the installer).
2. The live session starts through greetd → tuigreet → Hyprland.
3. Connect to the network — wired works out of the box, Wi-Fi via NetworkManager.

## Install to disk

Open a terminal (Ghostty) and run:

```sh
sudo novyra-install
```

The installer will:

1. Show your disks with `lsblk` and ask for the target disk.
2. Ask you to type `ERASE` to confirm — this wipes the selected disk.
3. Create a GPT layout with a 1 GiB EFI partition and an ext4 root partition.
4. Install the base system, Hyprland, greetd, tuigreet, Ghostty, Flatpak, and networking.
5. Configure the CachyOS repositories (optimized builds) and the novyra pacman repository.
6. Install systemd-boot and enable the first-boot service.

## First boot

After the first reboot, the one-time `novyra-first-boot` service runs once networking is available. It installs the remaining apps — paru, VS Code, Zed, Brave, LazyVim, and Warehouse — and adds Flathub. You can rerun it any time with:

```sh
sudo novyra-setup-apps
```

## Keeping novyra updated

Once installed, updates come straight from the novyra repository:

```sh
sudo pacman -Syu
```

The `[novyra]` repository is configured in the installed system, alongside the official Arch and CachyOS repositories.

## Building the ISO from source

If you'd rather build the ISO yourself, you need an Arch Linux environment with `archiso`:

```sh
sudo pacman -Syu archiso
RELEASE_CHANNEL=nightly RELEASE_VERSION=$(git rev-parse --short=7 HEAD) \
  scripts/build-iso.sh standard out
```

Use `nvidia` instead of `standard` for the NVIDIA variant.
