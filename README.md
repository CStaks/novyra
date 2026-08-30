# novyra-os

A highly opinionated Arch-based distro.

## Releases

- **Nightly** runs daily from `archlinux:latest` and uses the checked-out short commit hash.
- **Stable** runs only for `vMAJOR.MINOR.PATCH` tags and uses the pinned image in `config/arch-versions.env` (copy its value to the repository variable `STABLE_ARCH_IMAGE` when changing the pin).
- Each channel produces standard and NVIDIA ISOs.

SourceForge paths are exact and immutable per build:

```text
/nightly/<short-commit>/arch-custom-nightly-<short-commit>.iso
/nightly/<short-commit>/arch-custom-nightly-<short-commit>-nvidia.iso
/stable/<tag>/arch-custom-stable-<tag>.iso
/stable/<tag>/arch-custom-stable-<tag>-nvidia.iso
```

GitHub Releases contain only changelog text and direct SourceForge links. No ISO is attached to GitHub.

Required Actions secrets:

```text
SOURCEFORGE_USER
SOURCEFORGE_SSH_PRIVATE_KEY
NOVYRA_PACKAGE_SIGNING_KEY
NOVYRA_PACKAGE_SIGNING_KEY_ID
```

## ISO customization

Add packages one per line to `iso/packages.x86_64`. The ISO now includes Ghostty, lazygit, Neovim, Flatpak, and the CachyOS repository bootstrap. Zed, VS Code, Brave, LazyVim, Warehouse, and paru are installed by a one-time first-boot systemd service once networking is available. The same operation can be rerun manually with `sudo novyra-setup-apps`. Add files under `iso/airootfs/` at their final filesystem paths. The live image includes Hyprland, greetd, tuigreet, Ghostty, networking, and a basic UEFI installer available as:

```bash
sudo novyra-install
```

## Pacman repository

The ISO includes this configuration, and the installer writes it into the installed system:

```ini
[novyra]
SigLevel = Required DatabaseOptional
Server = https://sourceforge.net/projects/novyra/files/repo/$arch
```

Place built `.pkg.tar.zst` packages in `packages/`. The repository workflow imports the signing key, generates `novyra.db`/`novyra.files`, exports `novyra.gpg`, and uploads them to SourceForge. Users must import `novyra.gpg` into pacman before using `SigLevel = Required`.

There are currently no package recipes in this repository; adding package files or a package-builder workflow is required before Novyra packages can be delivered through `pacman -Syu`.

## Validation

```bash
bash scripts/validate-repo.sh
```

## Branding

novyra is always spelt with a lowercase n

### Dark Theme (Default)

| Color | Hex | RGB | Usage |
| :--- | :--- | :--- | :--- |
| **Background** | `#1C1C1C` | `rgb(28, 28, 28)` | Main application/body background |
| **Surface** | `#2A2A2A` | `rgb(42, 42, 42)` | Cards, modals, dropdowns, and elevated elements |
| **Primary Text** | `#FFFFFF` | `rgb(255, 255, 255)` | Headings and primary body text |
| **Secondary Text** | `#A1A1AA` | `rgb(161, 161, 170)` | Subtitles, placeholders, and muted text |
| **Borders** | `#3F3F46` | `rgb(63, 63, 70)` | Dividers, borders, and subtle line-work |

### Light Theme

| Color | Hex | RGB | Usage |
| :--- | :--- | :--- | :--- |
| **Background** | `#FFFFFF` | `rgb(255, 255, 255)` | Main application/body background |
| **Surface** | `#F4F4F5` | `rgb(244, 244, 245)` | Cards, modals, dropdowns, and elevated elements |
| **Primary Text** | `#1C1C1C` | `rgb(28, 28, 28)` | Headings and primary body text |
| **Secondary Text** | `#52525B` | `rgb(82, 82, 91)` | Subtitles, placeholders, and muted text |
| **Borders** | `#E4E4E7` | `rgb(228, 228, 231)` | Dividers, borders, and subtle line-work |

---

### Implementation Guidelines
* **Contrast:** Always ensure adequate contrast ratios. 
* **Flexibility:** When applying styles, try to use CSS variables instead of hardcoding colors

## License

[Apache 2.0](LICENSE)
