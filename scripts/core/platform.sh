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
  local normalized

  normalized="$(printf '%s:%s' "$xdg" "$session" | tr '[:upper:]' '[:lower:]')"

  # Explicit non-GNOME rejections first (including Pop!_OS COSMIC "pop")
  if [[ "$normalized" =~ (^|[:;])?(pop|kde|sway|xfce|i3|lxde|mate|cinnamon)($|[:;])? ]]; then
    return 1
  fi

  # Primary detection: XDG_CURRENT_DESKTOP contains gnome (GNOME, ubuntu:GNOME, GNOME-Classic)
  if [[ "${xdg,,}" =~ (^|[:;])gnome([:-]|$) ]]; then
    return 0
  fi

  # Fallback: DESKTOP_SESSION contains gnome
  if [[ "${session,,}" == *gnome* ]]; then
    return 0
  fi

  return 1
}
