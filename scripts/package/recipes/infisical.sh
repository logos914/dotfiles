infisical::install() {
  if platform::command_exists brew; then
    brew install infisical 2>&1 | log::file "Installing infisical via brew"
    return 0
  fi

  if platform::is_linux; then
    curl -fsSL https://infisical.com/install.sh 2>&1 |
      log::file "Installing infisical from infisical.com" |
      sh
    return $?
  fi

  return 1
}

infisical::is_installed() {
  platform::command_exists infisical
}
