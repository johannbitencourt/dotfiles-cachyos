# CachyOS System Notes

These notes describe the preferred CachyOS minimal + Hyprland system shape. They are not directly applied by user-level chezmoi.

## Desktop Layer

Install CachyOS minimal with no desktop environment. The desktop is assembled from explicit packages and user-level dotfiles.

Use the bootstrap to install the mandatory layer first:

```bash
./install/bootstrap.sh
```

Manual package install after `paru` is available:

```bash
sudo pacman -S --needed - < packages/pacman.txt
paru -S --needed - < packages/aur.txt
```

Do not install the dev/gaming/apps layers until Hyprland starts cleanly, the bar loads, the launcher opens, and lock/audio/network work.

Core services to enable after install:

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

Start Hyprland with:

```bash
uwsm start hyprland.desktop
```

UWSM defaults are managed in `~/.config/uwsm/`. Keep these files free of Omarchy paths and helper commands.

Avoid installing Omarchy on this system. If an Omarchy behavior is useful, recreate it as a small local script under `~/.config/hypr/scripts` or `~/.config/waybar/scripts`.

## Package Layers

Mandatory first-boot layer:

- `packages/pacman.txt`
- `packages/aur.txt`

Optional layers after the desktop is verified:

- `packages/dev-pacman.txt` and `packages/dev-aur.txt`
- `packages/gaming-pacman.txt` and `packages/gaming-aur.txt`
- `packages/apps-pacman.txt` and `packages/apps-aur.txt`

## Shell Layer

Use Bash as the login and interactive shell. The shell stack is intentionally small:

- Bash
- Starship
- bash-completion
- fzf
- zoxide
- mise

Do not install zsh or shell frameworks for this setup unless that decision changes later.

## Memory And Swap

Preferred setup for a 16 GB RAM laptop:

- zram device size: `ram / 2`
- zram compression: `zstd`
- zram priority: higher than disk swap, usually `100`
- disk swapfile: `8G`
- disk swapfile priority: lower than zram, usually `10`
- zswap: disabled when using zram
- default swappiness is acceptable; tune only if real pressure shows issues

Current reference setup:

```text
RAM: 16 GB class
zram: ~8 GB, zstd, priority 100
swapfile: ~8 GB, priority 10
zswap: disabled
```

Why:

- zram handles short memory pressure quickly without touching disk.
- the disk swapfile gives a fallback for heavy browser/dev/gaming sessions.
- zswap is redundant when zram is already the main compressed swap layer.

## Disk And Encryption

Preferred install layout:

```text
/boot: FAT32 EFI system partition
root: LUKS2 container
inside LUKS: Btrfs filesystem
```

Preferred Btrfs subvolumes:

```text
@      -> /
@home  -> /home
@pkg   -> /var/cache/pacman/pkg
@log   -> /var/log
```

Preferred Btrfs mount options:

```text
rw,relatime,compress=zstd:3,ssd,space_cache=v2
```

Optional data disk:

```text
/data: ext4, noatime, discard, exec
```

## Boot Cmdline

Use the installer-generated identifiers. Keep the model:

```text
cryptdevice=PARTUUID=<root-luks-partuuid>:root root=/dev/mapper/root rootfstype=btrfs rootflags=subvol=@ zswap.enabled=0 rw splash quiet
```

Do not copy UUIDs or PARTUUIDs from another machine.

## What Belongs In Chezmoi

Good candidates:

- Bash config
- terminal config
- Hyprland/Waybar/Walker/Mako user config
- Herdr config
- Neovim config
- Mise config
- Fastfetch config
- package manifests
- docs and examples

Avoid applying directly from user-level chezmoi:

- `/etc/fstab`
- `/etc/crypttab`
- `/etc/mkinitcpio.conf`
- bootloader entries
- `/etc/systemd/zram-generator.conf`
- `/etc/sysctl.d/*.conf`
