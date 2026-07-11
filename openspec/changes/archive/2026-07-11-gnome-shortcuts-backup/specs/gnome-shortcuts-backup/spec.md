# Delta for gnome-shortcuts-backup

## ADDED Requirements

### REQ-1: Backup GNOME Shortcuts

The system SHALL allow users to manually backup their current GNOME shortcuts.

#### Scenario: Backup on GNOME

- GIVEN the system is running GNOME (`platform::is_gnome` returns true)
- WHEN the user executes `dot gnome backup`
- THEN the system dumps default and custom keybindings (including `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/`) to `gnome/shortcuts.dconf`

#### Scenario: Backup on Non-GNOME

- GIVEN the system is not running GNOME
- WHEN the user executes `dot gnome backup`
- THEN the command fails cleanly with an error indicating GNOME is required

### REQ-2: Restore GNOME Shortcuts

The system SHALL allow users to manually restore their GNOME shortcuts from the backup file.

#### Scenario: Restore on GNOME with Backup

- GIVEN the system is running GNOME
- AND `gnome/shortcuts.dconf` exists
- WHEN the user executes `dot gnome restore`
- THEN the system idempotently loads the shortcuts via `dconf load` overwriting current settings cleanly

#### Scenario: Restore on Non-GNOME

- GIVEN the system is not running GNOME
- WHEN the user executes `dot gnome restore`
- THEN the command fails cleanly with an error indicating GNOME is required