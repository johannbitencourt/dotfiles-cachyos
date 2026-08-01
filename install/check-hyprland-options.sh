#!/usr/bin/env bash
set -euo pipefail

# Hyprland's config schema drifts across releases (options get renamed or
# removed, e.g. dwindle:pseudotile disappeared in 0.56.0). This walks every
# scalar `key = value` assignment inside dot_config/hypr/*.conf and checks it
# against `hyprctl getoption` on a *live* Hyprland session, so drift is caught
# before it shows up as a red error banner on next boot.
#
# Requires a running Hyprland instance to check against -- run this on any
# machine with Hyprland live (this dev box, or the target machine itself)
# before shipping a change to dot_config/hypr/*.conf.

if ! command -v hyprctl >/dev/null 2>&1 || ! hyprctl version >/dev/null 2>&1; then
  printf 'No live Hyprland session to check against. Run this from inside a Hyprland session.\n' >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Keyword directives, not scalar options -- hyprctl getoption doesn't apply.
is_directive() {
  case "$1" in
    bind|bindm|bindl|bindr|binde|bindel|bindn|bindni|bindo|binds) return 0 ;;
    env|exec|exec-once|source|monitor|workspace) return 0 ;;
    windowrule|windowrulev2|layerrule) return 0 ;;
    bezier|animation) return 0 ;;
    *) return 1 ;;
  esac
}

stale_found=0
checked=0

for conf_file in "$repo_dir"/dot_config/hypr/*.conf; do
  [[ -f $conf_file ]] || continue

  stack=()
  while IFS= read -r raw_line; do
    line="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/#.*$//' <<<"$raw_line")"
    [[ -z $line ]] && continue

    if [[ $line =~ ^([A-Za-z0-9_.]+)[[:space:]]*\{ ]]; then
      stack+=("${BASH_REMATCH[1]}")
      continue
    fi

    if [[ $line == "}" ]]; then
      if (( ${#stack[@]} > 0 )); then
        unset 'stack[-1]'
      fi
      continue
    fi

    if [[ $line =~ ^([A-Za-z0-9_.]+)[[:space:]]*= ]] && (( ${#stack[@]} > 0 )); then
      key="${BASH_REMATCH[1]}"
      is_directive "$key" && continue

      full="$(IFS=:; echo "${stack[*]}:$key")"
      checked=$((checked + 1))
      result="$(hyprctl getoption "$full" 2>&1)"
      if [[ $result == "no such option" ]]; then
        printf 'STALE: %s  (%s)\n' "$full" "${conf_file#"$repo_dir"/}"
        stale_found=1
      fi
    fi
  done < "$conf_file"
done

if (( stale_found )); then
  printf '\nFound stale config options above -- check the Hyprland wiki for renames before deleting.\n' >&2
  exit 1
fi

config_errors="$(hyprctl configerrors)"
if [[ -n $config_errors ]]; then
  printf '\nHyprland reports configuration errors:\n%s\n' "$config_errors" >&2
  exit 1
fi

printf 'Checked %d scalar option(s) across dot_config/hypr/*.conf -- all valid against Hyprland %s.\n' \
  "$checked" "$(hyprctl version | head -1 | grep -oP '(?<=Hyprland )\S+')"
