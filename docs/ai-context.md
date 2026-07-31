# AI Context

This repository is a Bash-based chezmoi source for a CachyOS minimal install with a custom Hyprland desktop. It is inspired by the previous Omarchy setup, but must not depend on Omarchy files, services, theme state, or `omarchy-*` helper commands at runtime.

Prefer small, explicit changes. Keep desktop config portable and user-level unless a file is deliberately placed under `system/examples/` as documentation.

Important managed configs:

- `dot_bashrc`: Bash shell setup, aliases, Starship, Mise, Zoxide.
- `dot_inputrc`: Readline behavior.
- `dot_config/ghostty/config`: Primary terminal config.
- `dot_config/hypr`: Hyprland, Hypridle, Hyprlock, and local helper scripts.
- `dot_config/uwsm`: UWSM session defaults and environment.
- `dot_config/xdg-terminals.list`: terminal preference for xdg-terminal-exec.
- `dot_config/waybar`: Waybar layout, style, theme, and local scripts.
- `dot_config/walker`: App launcher config.
- `dot_config/mako/config`: Notification daemon config.
- `dot_config/herdr/config.toml`: Terminal workspace/multiplexer config.
- `dot_config/nvim`: LazyVim-based Neovim setup.
- `dot_config/mise/config.toml`: Language/tool version manager.
- `dot_config/fastfetch/config.jsonc`: CachyOS/Hyprland-friendly system summary.
- `packages/pacman.txt`: Official repo packages.
- `packages/aur.txt`: AUR packages.
- `packages/dev-*`: Optional development tools after the desktop is stable.
- `packages/gaming-*`: Optional gaming layer after the desktop is stable.
- `packages/apps-*`: Optional extra apps and desktop utilities after the desktop is stable.
- `install/bootstrap.sh`: Recommended fresh-install entry point; installs only the mandatory desktop layer.
- `install/post-apply-check.sh`: Validates the mandatory desktop layer after chezmoi apply.

System-level install preferences are documented in `docs/system.md` and `system/examples/`. These are intentionally ignored by chezmoi and should not be applied directly into `$HOME`.

Fresh-install procedure is documented in `docs/first-install.md`.

Preferred desktop target:

- CachyOS minimal, no preinstalled desktop.
- Hyprland launched through UWSM.
- Waybar for the panel.
- Walker for application/search launcher.
- Mako for notifications.
- Hypridle and Hyprlock for idle and lock behavior.
- Ghostty as primary terminal.
- Herdr for terminal workspaces.
- LazyVim/Neovim for editing.
- Mise for Node/Bun/pnpm/Java/Zig/Odin.
- Steam, Heroic, Lutris, Wine, GameMode, MangoHud, Gamescope, and ProtonUp-Qt for gaming.

Package policy:

- Keep `packages/pacman.txt` and `packages/aur.txt` limited to the mandatory first-boot desktop layer.
- Put development tools in `packages/dev-*`.
- Put gaming packages in `packages/gaming-*`.
- Put nonessential apps and extra desktop utilities in `packages/apps-*`.

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
