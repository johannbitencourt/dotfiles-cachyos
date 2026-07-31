# First Install Checklist

Target: CachyOS minimal with no desktop environment.

## Installer Choices

- Choose minimal/no desktop.
- Use LUKS2 encrypted root if reinstalling the main machine.
- Prefer Btrfs root with subvolumes documented in `docs/system.md`.
- Do not install KDE, GNOME, or Omarchy.

## First Boot TTY

Install the minimum tools needed to fetch this repo:

```bash
sudo pacman -S --needed git
```

Clone or copy the repo to:

```text
~/dotfiles-cachyos
```

Run the mandatory bootstrap:

```bash
cd ~/dotfiles-cachyos
./install/bootstrap.sh
```

Start the desktop:

```bash
uwsm start hyprland.desktop
```

## First Desktop Checks

- `Super + Return` opens Ghostty.
- `Super + Space` opens Walker.
- Waybar is visible.
- Network and Bluetooth applets start.
- Audio keys change volume.
- `Print` creates a screenshot.
- `Super + Ctrl + L` locks the session.
- `Super + Shift + Space` toggles Waybar.

## After The Desktop Is Stable

Install optional layers as needed:

```bash
sudo pacman -S --needed - < packages/dev-pacman.txt
paru -S --needed - < packages/dev-aur.txt

sudo pacman -S --needed - < packages/gaming-pacman.txt
paru -S --needed - < packages/gaming-aur.txt

sudo pacman -S --needed - < packages/apps-pacman.txt
paru -S --needed - < packages/apps-aur.txt
```

## Monitor Note

`~/.config/hypr/monitors.conf` currently targets Johann's desk setup:

```text
DP-1 2560x1440@144
eDP-1 disabled
```

If the first Hyprland launch is on different hardware, edit `~/.config/hypr/monitors.conf` from TTY before starting Hyprland.
