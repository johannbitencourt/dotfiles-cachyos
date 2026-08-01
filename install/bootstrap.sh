#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if (( EUID == 0 )); then
  printf 'Run this installer as your regular user, not root.\n' >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  printf 'Cannot identify this operating system: /etc/os-release is missing.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ ${ID:-} != cachyos && " ${ID_LIKE:-} " != *" arch "* ]]; then
  printf 'This installer supports CachyOS and Arch-based systems only (found %s).\n' "${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

if [[ $(uname -m) != x86_64 ]]; then
  printf 'CachyOS desktop manifests currently support x86_64 only.\n' >&2
  exit 1
fi

for command_name in sudo pacman git; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is missing: %s\n' "$command_name" >&2
    exit 1
  fi
done

backup_stale_hyprland_lua() {
  local lua_config="$HOME/.config/hypr/hyprland.lua"

  if [[ -e $lua_config ]]; then
    mv "$lua_config" "$lua_config.bak.$(date +%s)"
  fi
}

sudo -v
"$repo_dir/install/packages.sh" core

chezmoi init --source "$repo_dir"
chezmoi apply
backup_stale_hyprland_lua

sudo systemctl enable --now NetworkManager
if systemctl list-unit-files bluetooth.service >/dev/null 2>&1; then
  sudo systemctl enable --now bluetooth
fi
systemctl --user enable --now pipewire pipewire-pulse wireplumber

"$repo_dir/install/post-apply-check.sh"

cat <<'EOF'

Mandatory desktop layer is installed.

Start Hyprland with:
  uwsm start hyprland.desktop

After the desktop is verified, optional layers are available:
  ./install/packages.sh apps
  ./install/packages.sh dev
  ./install/packages.sh gaming
  ./install/packages.sh system
EOF
