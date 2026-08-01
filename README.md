# CachyOS + DMS + Hyprland Dotfiles

Portable chezmoi dotfiles for a CachyOS minimal installation with Hyprland via
UWSM and DankMaterialShell (DMS) as the desktop shell. Omarchy is not required.

## Fresh Install

From a TTY on CachyOS minimal:

```bash
sudo pacman -S --needed git
git clone https://github.com/johannbitencourt/dotfiles-cachyos.git ~/dotfiles-cachyos
cd ~/dotfiles-cachyos
./install/bootstrap.sh
uwsm start hyprland.desktop
```

The bootstrap validates the OS, fully syncs the system while installing the core
package layer, asks before building any AUR package, applies chezmoi, enables
required services, and runs post-apply checks. It is safe to rerun.

For an existing provisioned system, apply only the managed files:

```bash
chezmoi init --source ~/dotfiles-cachyos
chezmoi diff
chezmoi apply
```

## Package Layers

Core is installed by bootstrap. Add optional layers only as needed:

```bash
./install/packages.sh apps
./install/packages.sh dev
./install/packages.sh gaming
./install/packages.sh system
```

| Layer | Purpose |
| --- | --- |
| `core` | Hyprland, UWSM, DMS, audio, network, shell, terminal, and daily desktop tools |
| `apps` | Extra GUI applications and fallback tray applets |
| `dev` | Containers, Git tooling, terminal utilities, and editors |
| `gaming` | Steam, Wine, Gamescope, MangoHud, and launchers |
| `system` | Storage, encryption, hardware diagnostics, and zram tooling |

Package manifests declare package names for a rolling CachyOS system; they are
not a version-locked system image. AUR recipes are third-party code, so package
names are shown and confirmation is required before installation. Review the
PKGBUILD when `paru` offers it. Set `DOTFILES_ALLOW_AUR=1` only for a
deliberately non-interactive install.

## Hardware Portability

The managed monitor default is safe on laptops, desktops, docks, and VMs:

```text
monitor = , preferred, auto, 1
```

Chezmoi creates `~/.config/hypr/monitors.local.conf` once and never overwrites
it. Put machine-specific output names, positions, refresh rates, and disabled
panels there. Do not edit the managed `monitors.conf` target.

NVIDIA variables are enabled only when an NVIDIA DRM device is detected. VMs
use Qt Quick software rendering unless explicit GPU passthrough is available.
These variables live in UWSM so the full graphical session receives them.

## Daily Use

```bash
chezmoi status
chezmoi diff
chezmoi add ~/.bashrc
chezmoi apply
```

Run `./install/post-apply-check.sh` after package or config changes. From a live
Hyprland session, run `./install/check-hyprland-options.sh` after changing
Hyprland options.

See `docs/first-install.md` for bring-up checks and `docs/system.md` for the
non-automated disk, encryption, and memory design. Files under
`system/examples/` are reference fragments and are never applied by chezmoi.
