---
name: Getting started
description: The first things to do after installing novyra.
---

# Getting started

novyra is an opinionated Arch-based desktop built around Hyprland, with thoughtful defaults and CachyOS repositories for faster apps. This page covers what's on the system and how to use it.

## What's preinstalled

- **Hyprland** — the Wayland compositor and desktop
- **greetd + tuigreet** — the login screen
- **Ghostty** — the default terminal
- **lazygit** and **Neovim (LazyVim)** — terminal git and editing
- **Flatpak** — with Flathub added on first boot
- **NetworkManager** — networking and the nm-applet

After first boot you'll also have paru, VS Code, Zed, Brave, Warehouse, and LazyVim configured.

## First steps

1. Update everything: `sudo pacman -Syu`
2. Open a terminal with `SUPER+RETURN`
3. Browse Flathub with Warehouse to add more apps
4. Use `paru` to install anything else from the AUR

## Key bindings

| Shortcut | Action |
| :--- | :--- |
| `SUPER+RETURN` | Open a terminal |
| `SUPER+Q` | Close the focused window |
| `SUPER+M` | Exit Hyprland |

## Staying up to date

novyra updates come from the `[novyra]` pacman repository, hosted on SourceForge and configured out of the box. Run `sudo pacman -Syu` and you're current — no extra steps needed.

More guides will be added as novyra grows.
