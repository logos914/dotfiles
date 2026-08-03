platform::command_exists() {
  type "$1" >/dev/null 2>&1
}

platform::is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

platform::is_macos_arm() {
  [[ $(uname -p) == "arm" ]]
}

platform::is_linux() {
  [[ $(uname -s) == "Linux" ]]
}

platform::is_wsl() {
  grep -qEi "(Microsoft|WSL|microsoft)" /proc/version &>/dev/null
}

platform::wsl_home_path() {
  wslpath "$(wslvar USERPROFILE 2>/dev/null)"
}

platform::is_gnome() {
  local xdg="${XDG_CURRENT_DESKTOP:-}"
  local session="${DESKTOP_SESSION:-}"

  local lower_xdg="$(printf '%s' "$xdg" | tr '[:upper:]' '[:lower:]')"
  local lower_session="$(printf '%s' "$session" | tr '[:upper:]' '[:lower:]')"
  local normalized="${lower_xdg}:${lower_session}"

  local reject_pattern="(^|[:;])?(pop|kde|sway|xfce|i3|lxde|mate|cinnamon)($|[:;])?"
  local gnome_pattern="(^|[:;])gnome([:-]|$)"

  # Explicit non-GNOME rejections first (including Pop!_OS COSMIC "pop")
  if [[ "$normalized" =~ $reject_pattern ]]; then
    return 1
  fi

  # Primary detection: XDG_CURRENT_DESKTOP contains gnome (GNOME, ubuntu:GNOME, GNOME-Classic)
  if [[ "$lower_xdg" =~ $gnome_pattern ]]; then
    return 0
  fi

  # Fallback: DESKTOP_SESSION contains gnome
  if [[ "$lower_session" == *gnome* ]]; then
    return 0
  fi

  return 1
}
