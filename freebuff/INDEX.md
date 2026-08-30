# Freebuff Repository Index

## Project

Novyra OS is an Arch-based Linux distribution. The repository contains the ArchISO profile, live filesystem configuration, installer, package repository tooling, and GitHub Actions distribution workflows.

## Important paths

| Path | Purpose |
| --- | --- |
| `iso/` | ArchISO profile and live filesystem contents |
| `iso/packages.x86_64` | Packages preinstalled in both ISO variants; add one package per line |
| `iso/airootfs/` | Files copied into the live filesystem at their final paths |
| `scripts/build-iso.sh` | Builds standard or NVIDIA ISO variants |
| `scripts/install-novyra.sh` | Canonical basic UEFI installer source |
| `scripts/build-package-repo.sh` | Generates pacman repository metadata |
| `scripts/release-vars.sh` | Computes release channel/version/path values |
| `scripts/validate-repo.sh` | Local shell/profile validation |
| `packages/` | Input directory for `.pkg.tar.zst` packages |
| `repo/x86_64/` | Generated pacman repository output |
| `config/arch-versions.env` | Documented stable Arch image pin |
| `.github/workflows/build-iso.yml` | Nightly/stable ISO build, SourceForge upload, GitHub release links |
| `.github/workflows/publish-repo.yml` | Signed pacman repository publication |
| `.github/workflows/coderabbit.yml` | Automated CodeRabbit pull request reviews |
| `.coderabbit.yaml` | CodeRabbit repository-specific review guidance |

## Release model

- Nightly: daily schedule, `archlinux:latest`, short Git commit hash.
- Stable: `vMAJOR.MINOR.PATCH` tags, pinned Arch image, tag as release version.
- Standard and NVIDIA ISOs are built for each channel.
- SourceForge paths are `/nightly/<hash>/` and `/stable/<tag>/`.
- GitHub Releases contain links only; ISOs are not attached.

## Preinstalled environment

The ISO includes Hyprland, greetd, tuigreet, Ghostty, lazygit, Neovim, Flatpak, networking, installer utilities, and CachyOS repository configuration. A one-time `novyra-first-boot.service` installs AUR applications and setup components after networking is available. It can be rerun with `sudo novyra-setup-apps`.

## Repository policy

- Preserve unrelated user changes.
- Do not edit `.env` files or print secrets.
- Do not commit, push, reset, clean, or rewrite history unless explicitly requested.
- Prefer editing existing files and use Freebuff file tools for source changes.
- Do not hand-edit generated files.
- Pull requests are reviewed by CodeRabbit using `.coderabbit.yaml`; workflow changes must preserve least-privilege permissions and avoid exposing secrets.

## Validation

Run:

```bash
bash scripts/validate-repo.sh
bash -n scripts/release-vars.sh
bash -n scripts/build-iso.sh
bash -n scripts/install-novyra.sh
bash -n iso/airootfs/usr/local/share/novyra/setup-apps.sh
 git diff --check
```

## extra info

- novyra is always spelt with a lowercase n
A full ISO build requires Arch Linux with `archiso`; a full package repository build requires Arch `repo-add`. Those cannot be substituted with generic Node tooling.

## Agent handoff

Read this file before changing the repository. Keep `AGENTS.md` and `CLAUDE.md` as pointers to this index so all agents use the same source of truth.
