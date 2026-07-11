# Spec: gnome-shortcuts-backup

## Purpose

Backup and restoration of GNOME default and custom keybindings to a versioned file in `gnome/shortcuts.dconf`, including custom keybindings under `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/...`.

## Requirements

### REQ-1: Manual backup of GNOME shortcuts

The system SHALL allow the user to manually invoke `dot gnome backup` to dump default and custom keybindings to `gnome/shortcuts.dconf` if GNOME is detected, otherwise fail cleanly with a non-crashing error.

#### Scenario: Backup on GNOME

- GIVEN the system is running GNOME (`platform::is_gnome` returns true)
- WHEN the user executes `dot gnome backup`
- THEN the system dumps default and custom keybindings (including `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/`) to `gnome/shortcuts.dconf`

#### Scenario: Backup on Non-GNOME

- GIVEN the system is not running GNOME
- WHEN the user executes `dot gnome backup`
- THEN the command fails cleanly with an error indicating GNOME is required

### REQ-2: Manual restore of GNOME shortcuts

The system SHALL allow the user to manually invoke `dot gnome restore` to load `gnome/shortcuts.dconf` into dconf idempotently if GNOME is detected, otherwise fail cleanly.

#### Scenario: Restore on GNOME with backup file present

- GIVEN the system is running GNOME
- AND `gnome/shortcuts.dconf` exists
- WHEN the user executes `dot gnome restore`
- THEN the system idempotently loads the shortcuts via `dconf load` overwriting current settings cleanly

#### Scenario: Restore on GNOME when backup file is missing

- GIVEN the system is running GNOME
- AND `gnome/shortcuts.dconf` does NOT exist
- WHEN the user executes `dot gnome restore`
- THEN the command fails cleanly indicating the backup file is missing

#### Scenario: Restore on non-GNOME

- GIVEN the system is not running GNOME
- WHEN the user executes `dot gnome restore`
- THEN the command fails cleanly with an error indicating GNOME is required
