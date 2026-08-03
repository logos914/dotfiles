# Change: gnome-shortcuts-backup

## Why

The user uses Debian with GNOME and has heavily customized keyboard shortcuts including custom keybindings. Today the installer assumes GNOME blindly (and crashes on non-GNOME hosts), and there is no way to version, share, or restore those shortcuts across machines. This change fixes the crash AND adds versioned backup/restore so the user can re-install dotfiles on any GNOME machine and have their workflow restored.

## What changes

- New command `dot gnome backup` that dumps the GNOME keyboard shortcuts (including custom subkeys) to `gnome/shortcuts.dconf` in the repo.
- New command `dot gnome restore` that loads `gnome/shortcuts.dconf` back into dconf.
- New file `gnome/shortcuts.dconf` (initially empty placeholder, populated by the user running `dot gnome backup`).
- New helper `platform::is_gnome` in `scripts/core/platform.sh`.
- Auto-restore wired into `scripts/self/utils/install.sh` after the install steps, gated by `platform::is_gnome`, gracefully skipping with a log entry if `gnome/shortcuts.dconf` is missing.
- Fix to existing installer: the already-present `gsettings set org.gnome.shell.keybindings...` calls in `scripts/self/utils/install.sh` get wrapped with `platform::is_gnome` so the installer no longer crashes on KDE/Sway/headless hosts.

## Impact

| Area | Impact | Description |
|------|--------|-------------|
| `scripts/core/platform.sh` | Modified | New `platform::is_gnome` helper |
| `scripts/gnome/backup` | New | New script to backup shortcuts via dconf dump |
| `scripts/gnome/restore` | New | New script to restore shortcuts via dconf load |
| `gnome/shortcuts.dconf` | New | Versioned artifact storing the dump |
| `scripts/self/utils/install.sh` | Modified | Add helper guards to existing gsettings calls, and add auto-restore hook |

No changes to `bin/dot`, `installer`, or other top-level dirs.

## Out of scope (Non-goals)

- No theme/font/extension backup
- No auto-backup pre-restore
- No multi-profile support
- No GNOME version migration
- No graphical UI

## Capabilities

> This section is the CONTRACT between proposal and specs phases.

### New Capabilities
- `gnome-shortcuts-backup`: Backup and restoration of GNOME default and custom keybindings to `gnome/shortcuts.dconf`.

### Modified Capabilities
- `installer`: The Linux installation process is gaining DE detection, preventing crashes on non-GNOME systems, and getting an auto-restore step.

## Approach (high level)

- Define a reliable `platform::is_gnome` check relying on `$XDG_CURRENT_DESKTOP`.
- Create the `dot gnome` CLI namespace by adding `scripts/gnome/backup` and `scripts/gnome/restore`.
- Backup will use `dconf dump` for `/org/gnome/settings-daemon/plugins/media-keys/` and standard shortcuts paths.
- Modify `scripts/self/utils/install.sh` to protect existing `gsettings` steps and invoke `dot gnome restore` automatically during setup on GNOME environments.
- Log gracefully if `gnome/shortcuts.dconf` does not exist during an auto-restore, bypassing the step.

## Open questions

None.

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Blind execution crashes installer on headless/KDE | Low (once fixed) | Add DE detection helper `platform::is_gnome` in installer scripts. |

## Rollback Plan

Revert the modified script `scripts/self/utils/install.sh` and `scripts/core/platform.sh`. Remove `scripts/gnome/`. If the user ran a restore, no automatic rollback is provided for their GNOME configuration except what GNOME's "Reset All" button offers natively.

## Success Criteria

- [ ] `dot gnome backup` creates or updates `gnome/shortcuts.dconf` with custom keybindings.
- [ ] `dot gnome restore` successfully applies keybindings to the system.
- [ ] `installer` does not crash on a headless/non-GNOME Linux VM.
- [ ] First-time install on a GNOME system automatically applies the backed-up shortcuts.