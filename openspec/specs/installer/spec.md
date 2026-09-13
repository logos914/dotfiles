# Spec: installer

## Purpose

Handles the Linux installation process and platform-specific configurations.

## Requirements

### REQ-1: Apply Linux custom settings conditionally based on the desktop environment

The system SHALL detect the desktop environment via `platform::is_gnome` and only apply GNOME keybindings (existing `gsettings set org.gnome.shell...` calls) when running under GNOME.
When GNOME is detected, the system SHALL additionally invoke the GNOME shortcuts restore step.
When GNOME is NOT detected, the system SHALL skip all GNOME settings and the restore step without crashing.

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
