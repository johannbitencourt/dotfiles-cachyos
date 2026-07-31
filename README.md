# Dotfiles for CachyOS Hyprland

Bash-based chezmoi dotfiles for a CachyOS minimal install with a custom Hyprland desktop.

## First Setup

```bash
sudo pacman -S --needed chezmoi git
chezmoi init --source ~/dotfiles-cachyos
chezmoi apply
```

Recommended bootstrap on a fresh CachyOS minimal install:

```bash
cd ~/dotfiles-cachyos
./install/bootstrap.sh
```

For a remote repo later:

```bash
chezmoi init --apply git@github.com:johannbitencourt/dotfiles-cachyos.git
```

## Daily Usage

```bash
chezmoi status
chezmoi diff
chezmoi add ~/.bashrc
chezmoi apply
```

## Packages

The recommended first install is intentionally small. Use the bootstrap to install only the mandatory desktop layer first:

```bash
./install/bootstrap.sh
```

Manual package install after `paru` is available:

```bash
sudo pacman -S --needed - < packages/pacman.txt
paru -S --needed - < packages/aur.txt
```

After Hyprland boots cleanly, install optional layers as needed:

```bash
sudo pacman -S --needed - < packages/dev-pacman.txt
paru -S --needed - < packages/dev-aur.txt

sudo pacman -S --needed - < packages/gaming-pacman.txt
paru -S --needed - < packages/gaming-aur.txt

sudo pacman -S --needed - < packages/apps-pacman.txt
paru -S --needed - < packages/apps-aur.txt
```

## Scope

This repo keeps the user-level desktop and development configuration for a clean CachyOS Hyprland setup. It intentionally does not depend on Omarchy at runtime.

Managed desktop components:

- Hyprland via UWSM
- Waybar
- Walker
- Mako
- Hypridle and Hyprlock
- Ghostty as primary terminal

Managed shell stack:

- Bash
- Starship
- bash-completion
- fzf
- zoxide
- mise

## Bring-Up Order

1. Install CachyOS minimal with no desktop.
2. Clone or copy this repo to `~/dotfiles-cachyos`.
3. Run `./install/bootstrap.sh` from the repo.
4. Start Hyprland with `uwsm start hyprland.desktop`.
5. Only after the desktop is stable, install optional `dev`, `gaming`, and `apps` manifests.

## AI Context

Read these files before changing system, development, terminal, gaming, or desktop setup:

```bash
docs/first-install.md
docs/system.md
docs/ai-context.md
packages/pacman.txt
packages/aur.txt
packages/dev-pacman.txt
packages/dev-aur.txt
packages/gaming-pacman.txt
packages/gaming-aur.txt
packages/apps-pacman.txt
packages/apps-aur.txt
system/examples/etc/systemd/zram-generator.conf
system/examples/etc/sysctl.d/99-memory.conf
system/examples/fstab.example
system/examples/cmdline.example
```

System-level files under `system/examples/` are documentation/examples only. Do not apply them with user-level chezmoi.
