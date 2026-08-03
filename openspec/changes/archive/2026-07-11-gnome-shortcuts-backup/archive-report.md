# Archive Report: gnome-shortcuts-backup

## Status

✅ ARCHIVED on 2026-07-11

## What shipped

This change delivers a versioned, cross-machine backup/restore flow for GNOME keyboard shortcuts (including custom keybindings under `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/...`), and as a side benefit fixes a latent installer crash on non-GNOME hosts.

User-visible behaviors introduced:

- `bin/dot gnome backup` — manually dump default + custom GNOME keybindings from dconf into `gnome/shortcuts.dconf` in the repo. Errors cleanly with "GNOME is required" on non-GNOME hosts.
- `bin/dot gnome restore` — manually load `gnome/shortcuts.dconf` back into dconf. Idempotent. Errors cleanly with "GNOME is required" on non-GNOME hosts; errors cleanly with "Backup file not found" when the file is missing; treats empty/whitespace-only files as a no-op.
- `bin/dot self install` on Linux (GNOME hosts only) — after applying existing `gsettings` shortcuts, automatically invokes `dot gnome restore` if `gnome/shortcuts.dconf` is present in the repo. Logs `no backup found, skipping restore` and continues if the backup is absent. If restore fails (e.g., invalid dconf content), the installer exits non-zero (pipefail-safety guaranteed).
- `bin/dot self install` on non-GNOME hosts — no longer crashes. Logs `skipping GNOME keybindings (not running on GNOME)` and continues the install.
- `gnome/shortcuts.dconf` placeholder — comment-only file committed so the auto-restore existence check resolves out-of-the-box and any accidental `dconf load` against it is a true no-op. User must run `dot gnome backup` on their main GNOME machine to populate real shortcuts.

| Capability | Change | Files | Commit(s) |
|------------|--------|-------|-----------|
| `gnome-shortcuts-backup` (new) | Added `platform::is_gnome` DE detection helper in core platform module | `scripts/core/platform.sh` | `aca27b1` |
| `gnome-shortcuts-backup` (new) | Added `dot gnome backup` dispatcher script | `scripts/gnome/backup` | `0e322c2` |
| `gnome-shortcuts-backup` (new) | Added `dot gnome restore` dispatcher script | `scripts/gnome/restore` | `965c24a` |
| `gnome-shortcuts-backup` (new) | Added comment-only placeholder artifact | `gnome/shortcuts.dconf` | `145032f` |
| `installer` (modified) | Guarded existing GNOME `gsettings` block with `platform::is_gnome` + `platform::command_exists gsettings` (fixes crash on non-GNOME) | `scripts/self/utils/install.sh` | `392d22b` |
| `installer` (modified) | Fixed latent shebang typo `#!/user/env bash` → `#!/usr/bin/env bash` | `scripts/self/utils/install.sh` (line 1) | `1f6beb2` |
| `installer` (modified) | Added auto-restore hook inside GNOME block; direct (non-piped) invocation of `dot gnome restore` to preserve failure semantics under `set -euo pipefail` | `scripts/self/utils/install.sh` | `2be7460` |
| Delivery | PR 1 merge to `master` (foundation) | — | `bf75491` |
| Delivery | PR 2 merge to `master` (backup/restore/placeholder + shebang fix) | — | `a223130` |
| Delivery | PR 3 merge to `master` (auto-restore hook) | — | `306486c` |

Total: 8 commits ahead of `origin/master`, 5 files changed, 154 insertions(+), 17 deletions(-).

## Source-of-truth specs (post-archive)

- `openspec/specs/gnome-shortcuts-backup/spec.md` — confirmed up-to-date, requirements REQ-1 (Manual backup of GNOME shortcuts, 2 scenarios) and REQ-2 (Manual restore of GNOME shortcuts, 3 scenarios: backup-present, backup-missing, non-GNOME). The third restore scenario (backup-missing) is a refinement over the delta that reflects the actual implementation behavior (`output::error "Backup file not found"` + exit 1).
- `openspec/specs/installer/spec.md` — confirmed up-to-date, REQ-1 (Apply Linux custom settings conditionally based on the desktop environment) with 3 scenarios (GNOME + backup / GNOME without backup / non-GNOME). Title and body updated to reflect the `platform::is_gnome`-gated behavior + auto-restore step.

No further delta merging is needed: the sdd-spec re-run performed during the change already consolidated both specs into `openspec/specs/`. The archived delta specs (under `specs/gnome-shortcuts-backup/spec.md` and `specs/installer/spec.md`) remain in the audit trail.

## Success criteria (from proposal.md)

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `dot gnome backup` creates or updates `gnome/shortcuts.dconf` with custom keybindings | ✓ DONE | Verified at shell level via `/tmp/opencode/sdd_pr3/run_verify.sh` — mocked `dconf` log contains all 3 required dumps (`/org/gnome/desktop/wm/keybindings/`, `/org/gnome/shell/keybindings/`, `/org/gnome/settings-daemon/plugins/media-keys/`), `BACKUP_RC=0`. Real-machine populating of actual shortcuts deferred to user. |
| `dot gnome restore` successfully applies keybindings to the system | ✓ DONE | Verified via mocked `dconf load /org/gnome/` — `RESTORE_RC=0` on present-file scenario. Missing-file and non-GNOME branches also verified. Real-machine end-to-end deferred to user. |
| `installer` does not crash on a headless/non-GNOME Linux VM | ✓ DONE | Verified via PR 1 Scenario A (non-GNOME smoke) — `INNER_RC=0`, zero gsettings/dconf invocations. Re-verified by `sdd-verify` per spec REQ-1 Scenario "Execute on Non-GNOME". |
| First-time install on a GNOME system automatically applies the backed-up shortcuts | ✓ DONE (automated restore) | Verified via PR 3 Scenario C (GNOME + valid placeholder) — `dconf load /org/gnome/` invoked once, `INNER_RC=0`, `output::answer "Restored GNOME shortcuts from gnome/shortcuts.dconf"` emitted. Real-machine populating of `gnome/shortcuts.dconf` (with the user's actual keybindings) deferred to user — the placeholder file is intentionally comment-only. |

## Diff summary

`git diff --stat origin/master..master`:

```
 gnome/shortcuts.dconf         |  3 ++
 scripts/core/platform.sh      | 27 +++++++-
 scripts/gnome/backup          | 44 +++++++++
 scripts/gnome/restore         | 43 +++++++++
 scripts/self/utils/install.sh | 54 +++++++++------
 5 files changed, 154 insertions(+), 17 deletions(-)
```

No scope leakage. All five files are exactly the expected set; `bin/dot`, `installer`, and other top-level dirs are untouched (per the proposal's "No changes to `bin/dot`, `installer`, or other top-level dirs").

## How to roll back

Per-PR revert (safe, preserves history):

1. `git revert -m 1 306486c` — reverts the PR 3 merge commit (auto-restore hook).
2. `git revert -m 1 a223130` — reverts the PR 2 merge commit (backup/restore + placeholder + shebang fix).
3. `git revert -m 1 bf75491` — reverts the PR 1 merge commit (`platform::is_gnome` + GNOME guard). Revert in this order (PR 3 → PR 2 → PR 1) so each revert step sees the prior PR's commits in place.

Single-shot clean slate (DESTRUCTIVE — only safe if you have not pushed yet):

4. `git reset --hard origin/master` — drops all 8 commits, returns to `origin/master`. Recommended only because the user explicitly chose to leave these commits unpushed.

User-state rollback (if a restore was already executed on a real GNOME host):

5. GNOME shortcuts can be reset via `gnome-control-center` → Keyboard → "Reset All…" (or the equivalent per-DE option). There is no automated rollback for shortcuts already written to dconf; users who want to revert individual keybindings must do so manually or via the GNOME Settings UI.

## Real-machine validation checklist for the user

Current host is non-GNOME; end-to-end GNOME behavior must be confirmed on a real machine. Recommended order:

1. On the user's main Debian GNOME machine:
   - Run `bin/dot gnome backup`. This populates `gnome/shortcuts.dconf` with the user's actual keybindings (replacing the comment-only placeholder).
   - Commit the now-real `gnome/shortcuts.dconf` and push.
2. On the same machine (or a fresh clone elsewhere on the same host):
   - Run `bin/dot self install`. Verify in `gnome-control-center` → Keyboard that the custom shortcuts (e.g., `Super+T` → Tilix) are present and that the install log shows `Restored GNOME shortcuts from gnome/shortcuts.dconf`.
3. On a second Debian GNOME machine or VM:
   - Clone the dotfiles repo (after step 1's push) and run `bin/dot self install`. Verify the same keybindings land. This is the cross-machine restore proof.
4. On a non-GNOME Linux VM (KDE, Sway, or headless Debian):
   - Run `bin/dot self install`. Verify it does NOT crash and that the log contains `skipping GNOME keybindings (not running on GNOME)`.
5. Optional regression check on a GNOME host with `gnome/shortcuts.dconf` deliberately deleted (or absent):
   - Run `bin/dot self install`. Verify log contains `no backup found, skipping restore` and installer exits 0.

## Follow-ups (NOT in this change)

- **Pre-existing shfmt/shellcheck warnings** in `shell/functions.sh`, `shell/bash/theme.sh`, `shell/zsh/theme.sh`, `scripts/dev/environment`, `scripts/symlinks/apply`, `bin/mb`. Repo-wide `dot self lint` and `dot self analysis` exit non-zero because of these unrelated issues. NOT touched; out of scope per proposal. Touched files in this change are clean under targeted `bash -n` / `shfmt -i 2 -d` / `shellcheck -s bash -S warning -e SC1090 -e SC2010 -e SC2154`.
- **Pre-existing modified dirty state** at the start of PR 1: `README.md`, `git/.gitconfig`, `shell/bash/.bashrc` modified; `.atl/`, `bin/mb`, `openspec/` untracked. Preserved through PR 1/2/3. NOT touched.
- **Suggestion from verify-report** (cosmetic, non-blocking): update `openspec/changes/gnome-shortcuts-backup/design.md` to remove the `| log::file "Restoring GNOME shortcuts"` mention in the "Installer integration" section, since PR 3 deliberately did NOT pipe the restore through `log::file` to preserve failure semantics (landmine #3 safeguard). The implementation already has an inline comment in `scripts/self/utils/install.sh` explaining this; syncing the design narrative is optional.
- **`bin/dot gnome -h` does not list sub-commands** — `bin/dot` only handles `-h` at top level. The intended convention is `bin/dot gnome backup -h` and `bin/dot gnome restore -h`, both of which route correctly. Verified in PR 2 task 2.4.
- **dconf on Snap/Flatpak sandboxes** — `dconf` bus access may fail under confinement. Script already exits non-zero in that case (no silent success); per-design landmine preserved.
- **Running installer as root** — dconf applies to root's profile, not target desktop user. PR 1 commit body documents this. `dot self install` should run as intended desktop user.