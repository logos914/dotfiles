#!/bin/user/env bash

install_macos_custom() {
  output::answer "Installing needed gnu packages"

  for package in coreutils make gnu-sed findutils bat hyperfine mas; do
    if ! brew list $package &>/dev/null; then
      output::answer "Installing $package"
      brew install $package | log::file "Installing brew $package"
    fi
    output::write "✅ $package installed"
  done
}

install_linux_custom() {
  output::answer "Installing and configuring system tools"

  # Ensure dependencies
  sudo apt update && sudo apt install -y neovim tilix xdotool wmctrl python3 python3-pip nodejs npm cargo ripgrep fd-find wget unzip

  # Install Nerd Fonts (FiraCode)
  output::answer "Installing FiraCode Nerd Font"
  mkdir -p "$HOME/.local/share/fonts"
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O /tmp/FiraCode.zip
  unzip -o -q /tmp/FiraCode.zip -d "$HOME/.local/share/fonts/"
  fc-cache -fv || true

  # Install LunarVim with PIP flag to bypass Debian PEP 668 restriction
  PIP_BREAK_SYSTEM_PACKAGES=1 LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh) --no-install-dependencies

  # Configure Shell Shortcuts
  if platform::is_gnome; then
    if platform::command_exists gsettings; then
      gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>c']"
      gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>m']" # Set Super+M for toggle-maximized

      # Configure Custom Shortcuts
      local custom0="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"

      # Tilix
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$custom0 name 'Tilix'
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$custom0 command 'tilix'
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$custom0 binding '<Super>t'

      # Set custom bindings (only custom0 for Tilix now)
      gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$custom0']"
    else
      output::answer "skipping GNOME keybindings (gsettings not found)"
    fi
  else
    output::answer "skipping GNOME keybindings (not running on GNOME)"
  fi
}
