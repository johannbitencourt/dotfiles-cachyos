#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ensure_paru() {
  if command -v paru >/dev/null 2>&1; then
    return
  fi

  if pacman -Si paru >/dev/null 2>&1; then
    sudo pacman -S --needed paru
    return
  fi

  local build_dir="${TMPDIR:-/tmp}/paru-build"

  rm -rf "$build_dir"
  git clone https://aur.archlinux.org/paru.git "$build_dir"
  (cd "$build_dir" && makepkg -si)
}

install_pacman_layer() {
  local file="$1"

  if [[ -s $file ]]; then
    sudo pacman -S --needed - < "$file"
  fi
}

install_aur_layer() {
  local file="$1"

  if [[ ! -s $file ]]; then
    return
  fi

  if ! command -v paru >/dev/null 2>&1; then
    printf 'paru is required for AUR packages. Install paru, then rerun this script.\n' >&2
    exit 1
  fi

  paru -S --needed - < "$file"
}

backup_stale_hyprland_lua() {
  local lua_config="$HOME/.config/hypr/hyprland.lua"

  if [[ -e $lua_config ]]; then
    mv "$lua_config" "$lua_config.bak.$(date +%s)"
  fi
}

sudo pacman -S --needed git chezmoi base-devel
ensure_paru

install_pacman_layer "$repo_dir/packages/pacman.txt"
install_aur_layer "$repo_dir/packages/aur.txt"

chezmoi init --source "$repo_dir"
chezmoi apply
backup_stale_hyprland_lua

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
systemctl --user enable --now pipewire pipewire-pulse wireplumber

"$repo_dir/install/post-apply-check.sh"

cat <<'EOF'

Mandatory desktop layer is installed.

Start Hyprland with:
  uwsm start hyprland.desktop

After the desktop is verified, optional layers are available:
  sudo pacman -S --needed - < packages/dev-pacman.txt
  paru -S --needed - < packages/dev-aur.txt
  sudo pacman -S --needed - < packages/gaming-pacman.txt
  paru -S --needed - < packages/gaming-aur.txt
  sudo pacman -S --needed - < packages/apps-pacman.txt
  paru -S --needed - < packages/apps-aur.txt
EOF
