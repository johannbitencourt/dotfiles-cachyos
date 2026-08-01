# First Install Checklist

Target: CachyOS minimal with no desktop environment.

## Installer Choices

- Choose minimal/no desktop.
- Prefer LUKS2 and Btrfs when reinstalling; see `docs/system.md`.
- Do not install KDE, GNOME, or Omarchy.
- Ensure the intended locale and user account are configured by the installer.

## Bring Up The Desktop

Follow the single fresh-install procedure in `README.md`. Bootstrap installs and
validates the desktop but deliberately does not start a compositor from inside
an existing session.

Start from the TTY with:

```bash
uwsm start hyprland.desktop
```

## Verify

- `Super + Return` opens Ghostty.
- `Super + Space` opens the DMS launcher.
- The DMS bar, notifications, control center, and polkit prompt work.
- Network, Bluetooth, audio, and brightness controls work in DMS.
- `Print` opens screenshot capture.
- `Super + Ctrl + L` locks the session.
- `Super + Ctrl + V` opens clipboard history.
- `Super + Shift + Space` toggles the DMS bar.
- `Super + Ctrl + N` toggles night mode.
- Battery notification runs only on machines with a battery.

Check Hyprland after the first launch:

```bash
hyprctl configerrors
./install/check-hyprland-options.sh
```

Both commands should complete without configuration errors.

## Per-Host Monitors

The generic monitor rule keeps every detected output usable. Add overrides to
`~/.config/hypr/monitors.local.conf`, which chezmoi creates once and leaves
unmanaged after creation:

```text
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = eDP-1, disable
```

Use output names from `hyprctl monitors all`. Keep the wildcard rule in the
managed `~/.config/hypr/monitors.conf` as a fallback when docking or moving the
same dotfiles to another machine.

## Optional Layers

After the core desktop is stable, use `./install/packages.sh <layer>` for
`apps`, `dev`, `gaming`, or `system`. The gaming layer requires the multilib
repository because it contains `lib32-*` packages.
