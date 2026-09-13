# Copies configuration back from $HOME into the dotfiles repository, for the
# tools that rewrite their config file instead of writing through the symlink.

config_sync::is_linked_to_dotfiles() {
  local -r origin="$1"
  local -r repository_path="$2"

  [ -L "$origin" ] && [ "$(readlink "$origin")" = "$repository_path" ]
}

config_sync::backup_item() {
  local -r origin="$1"
  local -r repository_path="$2"
  local -r name="$3"

  case "$repository_path" in
  "$DOTFILES_PATH"/?*) ;;
  *)
    output::error "Refusing to write \`$repository_path\`, it is outside of the dotfiles"
    return 1
    ;;
  esac

  if config_sync::is_linked_to_dotfiles "$origin" "$repository_path"; then
    return 0
  fi

  if [ ! -e "$origin" ]; then
    if [ -e "$repository_path" ]; then
      output::error "\`$name\` is versioned but missing in the system, keeping the dotfiles copy"
    fi

    return 0
  fi

  mkdir -p "$(dirname "$repository_path")"
  rm -rf "$repository_path"
  cp -R "$origin" "$repository_path"

  config_sync_backed_up_items=$((config_sync_backed_up_items + 1))

  output::solution "Backed up \`$name\`"
}

# Usage: config_sync::backup <origin_directory> <repository_directory> <item>...
# Leaves the number of copied items in `config_sync_backed_up_items`.
config_sync::backup() {
  local -r origin_directory="$1"
  local -r repository_directory="$2"
  shift 2

  config_sync_backed_up_items=0

  local item
  for item in "$@"; do
    config_sync::backup_item "$origin_directory/$item" "$repository_directory/$item" "$item"
  done
}
