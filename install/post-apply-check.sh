#!/usr/bin/env bash
set -euo pipefail

required_commands=(
  bash
  paru
  starship
  fzf
  zoxide
  mise
  hyprland
  uwsm
  waybar
  walker
  mako
  hyprlock
  hypridle
  ghostty
  grim
  slurp
  wl-copy
  pamixer
  playerctl
  notify-send
  xdg-terminal-exec
)

missing=()

for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    missing+=("$command_name")
  fi
done

if (( ${#missing[@]} > 0 )); then
  printf 'Missing required commands:\n' >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  jq empty "$HOME/.config/waybar/config.jsonc"
fi

require_font_match() {
  local query="$1"
  local expected="$2"
  local match

  if ! command -v fc-match >/dev/null 2>&1; then
    return
  fi

  match="$(fc-match -f '%{family}\n' "$query")"
  if [[ $match != *"$expected"* ]]; then
    printf 'Font query %s matched %s, expected %s\n' "$query" "$match" "$expected" >&2
    exit 1
  fi
}

require_font_match "CaskaydiaMono Nerd Font" "CaskaydiaMono Nerd Font"
require_font_match "Noto Sans" "Noto Sans"
require_font_match "Noto Color Emoji" "Noto Color Emoji"

required_files=(
  "$HOME/.config/hypr/hyprland.conf"
  "$HOME/.config/hypr/autostart.conf"
  "$HOME/.config/hypr/bindings.conf"
  "$HOME/.config/hypr/envs.conf"
  "$HOME/.config/hypr/input.conf"
  "$HOME/.config/hypr/looknfeel.conf"
  "$HOME/.config/hypr/monitors.conf"
  "$HOME/.config/hypr/theme.conf"
  "$HOME/.config/hypr/windows.conf"
  "$HOME/.config/uwsm/default"
  "$HOME/.config/uwsm/env"
  "$HOME/.config/xdg-terminals.list"
  "$HOME/.config/fontconfig/fonts.conf"
)

for file in "${required_files[@]}"; do
  if [[ ! -s $file ]]; then
    printf 'Required config is missing or empty: %s\n' "$file" >&2
    exit 1
  fi
done

if [[ -e $HOME/.config/hypr/hyprland.lua ]]; then
  printf 'Stale generated Hyprland config exists: %s\n' "$HOME/.config/hypr/hyprland.lua" >&2
  printf 'Back it up or remove it so Hyprland loads hyprland.conf.\n' >&2
  exit 1
fi

if grep -R 'omarchy\|OMARCHY_PATH' "$HOME/.config/uwsm" >/dev/null 2>&1; then
  printf 'UWSM config contains stale Omarchy references.\n' >&2
  exit 1
fi

scripts=(
  "$HOME/.config/hypr/scripts/lock"
  "$HOME/.config/hypr/scripts/screenshot"
  "$HOME/.config/hypr/scripts/toggle-waybar"
  "$HOME/.config/hypr/scripts/toggle-nightlight"
  "$HOME/.config/hypr/scripts/require-command"
  "$HOME/.config/hypr/scripts/color-picker"
  "$HOME/.config/hypr/scripts/start-polkit"
  "$HOME/.config/waybar/scripts/updates"
)

for script in "${scripts[@]}"; do
  if [[ ! -x $script ]]; then
    printf 'Script is missing or not executable: %s\n' "$script" >&2
    exit 1
  fi
done

if ! command -v hyprpolkitagent >/dev/null 2>&1 && \
   ! systemctl --user list-unit-files hyprpolkitagent.service >/dev/null 2>&1 && \
   ! [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
  printf 'No supported polkit authentication agent found.\n' >&2
  exit 1
fi

printf 'Post-apply checks passed.\n'
