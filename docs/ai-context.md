# AI Context

This repository is a Bash-based chezmoi source for a CachyOS minimal install with a custom Hyprland desktop. It is inspired by the previous Omarchy setup, but must not depend on Omarchy files, services, theme state, or `omarchy-*` helper commands at runtime.

Prefer small, explicit changes. Keep desktop config portable and user-level unless a file is deliberately placed under `system/examples/` as documentation.

Important managed configs:

- `dot_bashrc`: Bash shell setup, aliases, Starship, Mise, Zoxide.
- `dot_inputrc`: Readline behavior.
- `dot_config/ghostty/config`: Primary terminal config.
- `dot_config/hypr`: Hyprland config and local helper scripts. The managed monitor rule is hardware-neutral; `create_monitors.local.conf` creates a per-host override once without managing subsequent edits.
- `dot_config/uwsm`: UWSM session defaults and environment.
- `dot_config/herdr/config.toml`: Terminal workspace/multiplexer config.
- `dot_config/nvim`: LazyVim-based Neovim setup.
- `dot_config/mise/config.toml`: Language/tool version manager.
- `dot_config/fastfetch/config.jsonc`: CachyOS/Hyprland-friendly system summary.
- `packages/core-*`: Mandatory first-boot packages.
- `packages/dev-*`: Optional development tools after the desktop is stable.
- `packages/gaming-*`: Optional gaming layer after the desktop is stable.
- `packages/apps-*`: Optional extra apps and desktop utilities after the desktop is stable.
- `packages/system-*`: Optional storage and hardware administration tools.
- `install/bootstrap.sh`: The only fresh-install entry point; installs the mandatory desktop layer.
- `install/packages.sh`: Shared installer for all named package layers and the AUR trust prompt.
- `install/post-apply-check.sh`: Validates the mandatory desktop layer after chezmoi apply.
- `install/check-hyprland-options.sh`: Dev-time check, not part of bootstrap. Hyprland's config schema drifts across releases (options get renamed or removed -- e.g. `dwindle:pseudotile` was removed in 0.56.0). Run this against any machine with a *live* Hyprland session (it needs `hyprctl` talking to a running compositor, so it can't run during bootstrap before Hyprland has ever started) before or after touching `dot_config/hypr/*.conf`, to catch stale options before they surface as a red error banner on next boot.

System-level install preferences are documented in `docs/system.md` and `system/examples/`. These are intentionally ignored by chezmoi and should not be applied directly into `$HOME`.

Fresh-install procedure is documented in `docs/first-install.md`.

Preferred desktop target:

- CachyOS minimal, no preinstalled desktop.
- Hyprland launched through UWSM.
- DMS (DankMaterialShell, `dms-shell-hyprland` package) for panel, launcher, notifications, control center, idle/lock, on-screen displays, and polkit authentication -- replaces the previous Waybar/Walker/Mako/Hypridle/Hyprlock/hyprpolkitagent stack. Started via `exec-once = dms run` in `autostart.conf`; controlled via `dms ipc call <target> <function>` from Hyprland keybinds (see `dot_config/hypr/bindings.conf`). DMS's own runtime state (`~/.config/DankMaterialShell`, `~/.local/state/DankMaterialShell`, `~/.cache/DankMaterialShell`) is deliberately excluded from chezmoi via `.chezmoiignore` -- it's generated/edited through DMS's own Settings UI, not hand-authored.
- Deliberately not using DMS's optional `~/.config/hypr/hyprland.lua` colors/layout/outputs integration -- keep Hyprland's own borders/gaps/blur driven by the existing `theme.conf`/`looknfeel.conf`, and keep `hyprland.lua` out of the picture (see the stale-file check in `install/bootstrap.sh`/`post-apply-check.sh`).
- Not using DMS's optional `dank-greeter` (graphical login) -- keep booting to a TTY and running `uwsm start hyprland.desktop` manually.
- Ghostty as primary terminal.
- Herdr for terminal workspaces.
- LazyVim/Neovim for editing.
- Mise for Node/Bun/pnpm/Java/Zig/Odin.
- Steam, Heroic, Lutris, Wine, GameMode, MangoHud, Gamescope, and ProtonUp-Qt for gaming.

Package policy:

- Keep `packages/core-*` limited to the mandatory first-boot desktop layer.
- Put development tools in `packages/dev-*`.
- Put gaming packages in `packages/gaming-*`.
- Put nonessential apps and extra desktop utilities in `packages/apps-*`.
- Put storage, encryption, and hardware administration tools in `packages/system-*`.

Preferred shell stack:

- Bash only; do not add zsh, fish, oh-my-zsh, or shell-framework dependencies.
- Starship prompt.
- bash-completion for command completion.
- fzf for fuzzy keybindings/completion.
- zoxide for directory jumping.
- mise for language/tool versions.

Do not add references to:

- `~/.local/share/omarchy`
- `~/.config/omarchy`
- `$OMARCHY_PATH`
- `omarchy-*` commands

Preferred storage/memory model:

- LUKS2 encrypted root.
- Btrfs root with zstd compression and subvolumes.
- zram as primary swap with higher priority.
- disk swapfile as lower-priority fallback.
- zswap disabled when zram is used.
