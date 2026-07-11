# Delta for installer

## MODIFIED Requirements

### REQ-1: Apply Linux Custom Settings

The system SHALL apply custom Linux configurations conditionally based on the desktop environment.
(Previously: The system applies GNOME keybindings unconditionally without checking the desktop environment)

#### Scenario: Execute on GNOME with Backup

- GIVEN the environment is GNOME (`platform::is_gnome` returns true)
- AND `gnome/shortcuts.dconf` exists in the repository
- WHEN the user runs `dot self install` on Linux
- THEN the system applies the existing GNOME keybindings via gsettings
- AND the system auto-restores the backup via `dot gnome restore`

#### Scenario: Execute on GNOME without Backup

- GIVEN the environment is GNOME
- AND `gnome/shortcuts.dconf` does NOT exist in the repository
- WHEN the user runs `dot self install` on Linux
- THEN the system applies the existing GNOME keybindings via gsettings
- AND logs "no backup found, skipping restore"
- AND continues without prompting or creating defaults

#### Scenario: Execute on Non-GNOME

- GIVEN the environment is NOT GNOME
- WHEN the user runs `dot self install` on Linux
- THEN the system skips all GNOME keybindings and auto-restore
- AND continues the installation without crashing