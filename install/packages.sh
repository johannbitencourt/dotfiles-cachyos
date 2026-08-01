#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
layer="${1:-}"

case "$layer" in
  core|apps|dev|gaming|system) ;;
  *)
    printf 'usage: %s <core|apps|dev|gaming|system>\n' "$0" >&2
    exit 2
    ;;
esac

if (( EUID == 0 )); then
  printf 'Run this script as your regular user, not root.\n' >&2
  exit 1
fi

for command_name in sudo pacman; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is missing: %s\n' "$command_name" >&2
    exit 1
  fi
done

if [[ $layer == gaming ]] && ! pacman-conf --repo-list 2>/dev/null | grep -qx multilib; then
  printf 'The gaming layer requires the multilib repository. Enable it before continuing.\n' >&2
  exit 1
fi

pacman_file="$repo_dir/packages/$layer-pacman.txt"
aur_file="$repo_dir/packages/$layer-aur.txt"

if [[ -s $pacman_file ]]; then
  if [[ $layer == core ]] && ! pacman -Si dms-shell-hyprland >/dev/null 2>&1; then
    printf 'Core package dms-shell-hyprland is not available from the current pacman databases.\n' >&2
    printf 'Refreshing package databases before installing the core desktop layer.\n' >&2
  fi

  sudo pacman -Syu --needed - < "$pacman_file"

  if [[ $layer == core ]] && ! command -v dms >/dev/null 2>&1; then
    printf 'Core install finished, but the dms command is still missing.\n' >&2
    printf 'Check that dms-shell-hyprland and dms-shell installed successfully.\n' >&2
    exit 1
  fi
fi

if [[ ! -s $aur_file ]]; then
  exit 0
fi

if [[ ${DOTFILES_ALLOW_AUR:-0} != 1 ]]; then
  printf '\nThe %s layer contains third-party AUR packages:\n' "$layer"
  sed 's/^/  /' "$aur_file"
  if [[ ! -t 0 ]]; then
    printf 'Review the package recipes, then rerun interactively or set DOTFILES_ALLOW_AUR=1.\n' >&2
    exit 1
  fi
  read -r -p 'Build and install these AUR packages? [y/N] ' answer
  if [[ $answer != [yY] && $answer != [yY][eE][sS] ]]; then
    if [[ $layer == core ]]; then
      printf 'The core layer was not fully installed.\n' >&2
      exit 1
    fi
    exit 0
  fi
fi

if ! command -v paru >/dev/null 2>&1; then
  sudo pacman -S --needed git base-devel
  if pacman -Si paru >/dev/null 2>&1; then
    sudo pacman -S --needed paru
  else
    (
      build_dir="$(mktemp -d "${TMPDIR:-/tmp}/paru-build.XXXXXX")"
      trap 'rm -rf "$build_dir"' EXIT
      git clone https://aur.archlinux.org/paru.git "$build_dir"
      cd "$build_dir"
      makepkg -si
    )
  fi
fi

paru -S --needed - < "$aur_file"
