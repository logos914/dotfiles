## Exploration: gnome-shortcuts-backup

### Current State
The `.dotfiles` repo uses a bash-based monolithic installer (`installer`) that clones the repository and then delegates to a command dispatcher (`bin/dot`). `bin/dot` exposes a `self` context (`dot self install`), which triggers `scripts/self/install`. For Linux, it runs `install_linux_custom` defined in `scripts/self/utils/install.sh`. 

Currently, `install_linux_custom` blindly runs GNOME `gsettings` commands for custom keybindings, without verifying if the system is running GNOME. Symlinks are managed by `scripts/symlinks/apply`, where paths are hardcoded with no explicit `.d/` drop-in extension system.

### Affected Areas
- `scripts/self/utils/install.sh` — The main Linux installation hooks where we currently hardcode the GNOME shortcuts. It needs DE detection.
- `scripts/core/platform.sh` — Should be updated to provide DE detection (e.g., `platform::is_gnome()`).
- `bin/dot` (Dispatcher) — Will natively pick up any new context we add.
- `scripts/gnome/` — New directory that will contain `backup` and `restore` scripts.
- `installer` & `scripts/self/install` — Entry points that might call the new restore hook.

### Approaches
1. **Standalone scripts via `dot gnome`**
   - Pros: Fully isolates GNOME logic from the generic installer; fits cleanly with the existing dispatcher (`dot gnome backup`, `dot gnome restore`).
   - Cons: Adds a new context top-level.
   - Effort: Low.
2. **Hardcoded inside `install_linux_custom`**
   - Pros: Avoids new directories.
   - Cons: Makes `install_linux_custom` even larger; no clean way to expose "backup" manually.
   - Effort: Low.

### Recommendation
Adopt **Approach 1**. We create a new context at `scripts/gnome/` with two scripts: `backup` and `restore`. This will automatically expose them via the `bin/dot` dispatcher as `dot gnome backup` and `dot gnome restore`. We will hook `dot gnome restore` into `scripts/self/utils/install.sh`, but protect it using a new `platform::is_gnome` helper to check `$XDG_CURRENT_DESKTOP`.

### Risks
- **Blind execution**: If we run GNOME configuration scripts on headless servers or non-GNOME environments (like KDE or Sway), `dconf` or `gsettings` will crash the installer (due to `set -euo pipefail`).
- **Differing versions**: GNOME version discrepancies can alter `gsettings` paths, though backing up via `dconf dump` usually works well across recent versions.

### Ready for Proposal
Yes — the orchestrator has all the context needed to propose the design.