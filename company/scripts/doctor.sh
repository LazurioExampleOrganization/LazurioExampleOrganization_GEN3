#!/usr/bin/env bash
# AgentMint GEN2 doctor — health check, sync, push entry point pro macOS.
# Windows ekvivalent: doctor.ps1 (parita subcommandů + formátu výstupu).
#
# Subcommands:
#   doctor                — default: status
#   doctor status         — přehled modulů a stavu super-repa
#   doctor sync           — pull super-repa + sync nested repo modules
#   doctor sync --rebase  — navíc rebase lokálních commitů
#   doctor push -m "<msg>" --module <path> --include <path>
#                         — scoped commit + push nested repo/root změn
#   doctor check          — full health check
#   doctor check --quick  — jen kritické checks
#   doctor check --fix    — lokální nedestruktivní repair + re-check
#   doctor repair-local   — totéž co doctor check --fix, bez externích write akcí
#   doctor check-my-context — co z kaskády AGENTS.md se na mě vztahuje
#   doctor workspace-tasks — validate TODO.tasks.json / DONE.tasks.json / ISSUES.open.json
#   doctor init           — initial workspace setup po čistém clone
#   doctor deps-status    — přehled stavu node_modules v modulech
#   doctor deps-status --json — strojová verze pro Launchpad UI
#   doctor install-deps   — bun install ve všech Node projektech s chybějícími/rozbitými deps
#   doctor install-deps --all      — i v těch, co už vypadají zdravě
#   doctor install-deps --module=ID|PATH — jen v daném nested repo app scope
#   doctor install-launchpad — nainstaluje macOS Launchpad GEN2 app a přidá ji do Docku
#   doctor pullable       — fetch origin a report, které nested repo moduly mají nové commity
#   doctor pullable --json          — strojová verze pro Launchpad UI
#   doctor pullable --pull          — navíc udělá fast-forward pull kde lze
#   doctor pullable --no-fetch      — přeskočí fetch (použije cached refs)
#   doctor pullable --pullable-only — vynechá "aktuální" moduly z reportu
#   doctor port <N>       — identifikuje proces, co drží port N
#   doctor port <N> --json          — strojová verze pro Launchpad UI
#   doctor port <N> --kill          — odešle SIGTERM procesu
#
# Dokumentace v company/scripts/README.md §Doctor.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST="${ROOT_DIR}/modules.manifest.json"
if [[ ! -f "$MANIFEST" ]]; then
  MANIFEST="${ROOT_DIR}/company/scripts/modules.manifest.json"
fi
FIXES_DIR="${SCRIPT_DIR}/doctor/fixes"

# --- Output helpers (color if TTY) ---

if [[ -t 1 ]]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_FAIL=$'\033[31m'
  C_HINT=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_OK=""; C_WARN=""; C_FAIL=""; C_HINT=""; C_DIM=""; C_RST=""
fi

ok()   { printf '  %s[ok]%s   %s\n' "$C_OK" "$C_RST" "$*"; }
warn() { printf '  %s[warn]%s %s\n' "$C_WARN" "$C_RST" "$*"; WARN_COUNT=$((WARN_COUNT+1)); }
fail() { printf '  %s[fail]%s %s\n' "$C_FAIL" "$C_RST" "$*"; FAIL_COUNT=$((FAIL_COUNT+1)); }
hint() { printf '       %s→%s %s\n' "$C_HINT" "$C_RST" "$*"; }
hint_meta() { printf '       owner: %s | risk: %s\n' "$1" "$2"; }
hint_classified() {
  local owner="$1" risk="$2"
  shift 2
  hint "$*"
  hint_meta "$owner" "$risk"
}
header() { printf '\n%s== %s ==%s\n' "$C_DIM" "$*" "$C_RST"; }

WARN_COUNT=0
FAIL_COUNT=0

print_usage() {
  cat <<'EOF'
Usage: doctor <command> [options]

Commands:
  status              Show workspace and module status
  sync                Pull super-repo and sync nested repo modules
  push                Commit and push scoped workspace changes
  check               Run health checks
  check --template-placeholders
                      Scan remaining <VYPLNIT_*> placeholders
  repair-local        Repair local-only bootstrap issues, then re-check
  check-my-context    Show applicable AGENTS.md context
  workspace-tasks     Validate Git-native workspace task files
  init                Initialize nested repos and dependencies after clone
  deps-status         Check Node dependency health
  install-deps        Install missing/broken Node dependencies
  install-launchpad   Install Launchpad GEN2 macOS app and Dock item
  pullable            Show modules with remote updates
  port <N>            Show process using a port

Run "doctor <command> --help" for command-specific help.
EOF
}

print_status_usage() {
  cat <<'EOF'
Usage: doctor status

Shows workspace and module status.

Side effects: none.
EOF
}

print_check_usage() {
  cat <<'EOF'
Usage:
  doctor check [--quick] [--person=<id>] [--fix] [--template-placeholders]

Runs workspace health checks.

Options:
  --quick        Run only critical checks.
  --person=<id> Run person-specific bootstrap checks.
  --fix          Run local-only, non-destructive repairs, then re-check.
  --template-placeholders
                 Only scan remaining <VYPLNIT_*> placeholders.
  -h, --help     Show this help.

Side effects: none by default. With --fix, may copy missing .env.local files
from .env.example, install missing node_modules with frozen lockfiles, install
missing coworker-machine CLI tools through Homebrew on macOS, and switch clean
detached nested repo modules back to their expected branch when HEAD is already at that
branch tip. It never commits, pushes, rebases, root-pulls, or overwrites an
existing .env.local.
EOF
}

print_repair_local_usage() {
  cat <<'EOF'
Usage:
  doctor repair-local [--quick] [--person=<id>]

Runs the same local-only repair flow as doctor check --fix and then re-runs
doctor check.

It may:
  - create a missing .env.local from .env.example when .env.local is absent
  - install missing/broken node_modules with frozen lockfiles
  - switch a clean detached nested repo module back to its expected branch when safe

It never commits, pushes, rebases, root-pulls, edits dirty nested repo modules, or
overwrites an existing .env.local.

Options:
  --quick        Re-run only critical checks after repair.
  --person=<id> Run person-specific bootstrap checks.
  -h, --help     Show this help.

Side effects: local-only filesystem repairs listed above.
EOF
}

print_check_my_context_usage() {
  cat <<'EOF'
Usage: doctor check-my-context

Shows which AGENTS.md and skill layers apply to the current working directory.

Side effects: none.
EOF
}

print_workspace_tasks_usage() {
  cat <<'EOF'
Usage: doctor workspace-tasks

Validates Git-native workspace task files:
  - TODO.tasks.json for live executable work
  - DONE.tasks.json for completed or archived work
  - ISSUES.open.json for unresolved decisions

The validator also checks that any TODO.md next to a TODO.tasks.json is only a
legacy pointer and does not contain live Markdown checkbox tasks.

Side effects: none.
  -h, --help   Show this help.
EOF
}

print_sync_usage() {
  cat <<'EOF'
Usage:
  doctor sync [--rebase]

Pulls the super-repo when the root working tree is clean and syncs safe,
clean nested repo modules from root modules.manifest.json (legacy fallback:
company/scripts/modules.manifest.json).
Dirty nested repo modules are skipped.

Options:
  --rebase     Use git pull --rebase for the super-repo instead of --ff-only.
  -h, --help   Show this help.

Side effects: may pull the super-repo and update safe nested repo modules.
The super-repo never stores module pointer commits in the nested repo model.
EOF
}

print_init_usage() {
  cat <<'EOF'
Usage:
  doctor init [--skip-deps] [--skip-launchpad-install] [--skip-dock] [--check|--quick-check|--no-check] [--skip-disk-check]

Initializes a freshly cloned AgentMint GEN2 workspace:
  1. clones active nested repos from root modules.manifest.json
  2. verifies their expected branches from the manifest
  3. installs missing Node/Bun dependencies unless --skip-deps is used
  4. installs Launchpad GEN2 app on macOS unless --skip-launchpad-install is used
  5. runs a final health check

Options:
  --skip-deps    Do not run doctor install-deps.
  --skip-launchpad-install
                 Do not install the macOS Launchpad GEN2 app / Dock item.
  --skip-dock    Install/update the Launchpad GEN2 app but do not modify Dock.
  --check        Run full doctor check after initialization.
  --quick-check  Run doctor check --quick after initialization (default).
  --no-check     Skip the final doctor check.
  --skip-disk-check
                 Do not require the default free-space threshold.
  -h, --help     Show this help.

Side effects: may clone nested repos, write node_modules / lockfile updates,
and on macOS may install/update the Launchpad GEN2 app and Dock item.
EOF
}

print_install_launchpad_usage() {
  cat <<'EOF'
Usage:
  doctor install-launchpad [--skip-dock]

Installs the workspace-bound Launchpad GEN2 launcher for the current OS.

On macOS: builds and installs the AgentMint Launchpad GEN2.app bundle and
makes it easy to find from the Dock.

On Apple Silicon the installed launcher must be a native Mach-O arm64
executable. If macOS asks for Rosetta, do not install Rosetta for Launchpad;
rerun this command from the current workspace and verify:

  file "$HOME/Applications/AgentMint Launchpad GEN2.app/Contents/MacOS/AgentMint Launchpad GEN2"
  lipo -archs "$HOME/Applications/AgentMint Launchpad GEN2.app/Contents/MacOS/AgentMint Launchpad GEN2"

On Linux: installs an XDG Desktop Entry under
~/.local/share/applications/agentmint-launchpad-gen2.desktop plus a launcher
script under ~/.local/bin/agentmint-launchpad-gen2 that starts the bun server
and opens the local URL in the default browser. --skip-dock is accepted but
has no effect on Linux (there is no Dock).

Options:
  --skip-dock   Install/update the app bundle but do not modify the Dock.
  -h, --help    Show this help.

Side effects: on macOS, may write ~/Applications/AgentMint Launchpad GEN2.app
and may update com.apple.dock persistent-apps. On Linux, may write under
~/.local/share/applications, ~/.local/share/icons and ~/.local/bin.
EOF
}

print_push_usage() {
  cat <<'EOF'
Usage:
  doctor push -m "<message>" [--module <path>...] [--include <path>...] [--yes]
  doctor push "<message>" [--module <path>...] [--include <path>...] [--yes]

Common examples:
  doctor push -m $'Workspace: Update experiment checklist\n\nClarify the first AgentMint experiment guardrails.' \
    --include TODO.tasks.json \
    --include ISSUES.open.json \
    --yes

  doctor push -m $'Guide: Align task ledger lesson\n\nUpdate onboarding to match the AgentMint workflow.' \
    --include guide

Options:
  -m, --message <text>       Commit message base. Positional message is kept
                             for compatibility.
  --module <path>            Dirty nested repo module to commit and push. Repeatable.
                             Without --module, doctor only auto-selects when
                             exactly one non-sensitive dirty nested repo exists.
  --all                     Commit all eligible dirty nested repos. Use this
                             intentionally for multi-module maintenance.
  --include <path>           Root/super-repo path to include. Repeatable.
                             No implicit root "git add -A" is performed.
  --include-sensitive <path> Include sensitive root paths such as .claude/,
                             broad company/, company/colleagues/, infra/, or
                             infra/access/. Repeatable.
  --firebase-production-synced
                            Required when committing modules/firebase/mirror.
                            Confirms targeted production Firestore dry-run/write
                            was handled or explicitly deferred in the report.
  --dry-run                 Show what would be committed and pushed.
  -y, --yes                 Do not ask for interactive confirmation.
  -h, --help                Show this help.

Safety notes:
  - Commit messages feed release notes. Use a subject plus body that says
    what changed, why, and operational impact.
  - Split unrelated module changes into separate doctor push runs. Batch
    multiple modules only when they are one logical release-note item.
  - modules/monorepo and modules/firmware keep their own workflows.
  - infra must be selected explicitly with --module infra or --all.
  - Skipped module pointers are never staged into the super-repo commit.
  - Pokud vybraný modul používá @workspace-contracts/v1 a launchpad/contracts
    je dirty, přidej ho explicitně (např. --include launchpad/contracts).
EOF
}

print_pullable_usage() {
  cat <<'EOF'
Usage:
  doctor pullable [--json] [--pull] [--no-fetch] [--pullable-only]

Shows which repos have remote commits available.

Options:
  --json           Print machine-readable JSON for Launchpad.
  --pull           Fast-forward pull repos that are only behind.
  --no-fetch       Use cached origin refs.
  --pullable-only  Hide repos that are already current.
  -h, --help       Show this help.

Side effects: fetches origin refs by default. With --pull, may update repos.
EOF
}

print_port_usage() {
  cat <<'EOF'
Usage:
  doctor port <port> [--json] [--kill]

Shows which local process listens on a TCP port.

Options:
  --json       Print machine-readable JSON for Launchpad.
  --kill       Send SIGTERM to the listening process.
  -h, --help   Show this help.

Side effects: none by default. With --kill, sends SIGTERM.
EOF
}

print_install_deps_usage() {
  cat <<'EOF'
Usage:
  doctor install-deps [--all] [--force] [--module=<id-or-path>]

Runs bun install in Launchpad and module app directories that need it.

Options:
  --all          Include projects that already look healthy.
  --force        Force install even when dependency health looks OK.
  --module=<id-or-path>
                 Limit to a nested repo app directory, e.g. knowledgebase
                 or mission-control.
  -h, --help     Show this help.

Side effects: may write node_modules and lockfile updates.
EOF
}

print_deps_status_usage() {
  cat <<'EOF'
Usage:
  doctor deps-status [--json]

Checks Node/Bun dependency health for Launchpad and module apps.

Options:
  --json       Print machine-readable JSON for Launchpad.
  -h, --help   Show this help.

Side effects: none, except bun dry-run cache reads/writes.
EOF
}

has_help_arg() {
  local arg
  for arg in "$@"; do
    [[ "$arg" == "-h" || "$arg" == "--help" ]] && return 0
  done
  return 1
}

# --- Dependency checks ---

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf '%s[fail]%s Missing required command: %s\n' "$C_FAIL" "$C_RST" "$1" >&2
    exit 2
  fi
}

expand_doctor_path() {
  local value="$1"
  value="${value//\$\{HOME\}/$HOME}"
  value="${value//\$\{WORKSPACE_ROOT\}/$ROOT_DIR}"
  echo "$value"
}

path_matches_type() {
  local path="$1" kind="${2:-any}"
  case "$kind" in
    file) [[ -f "$path" ]] ;;
    dir)  [[ -d "$path" ]] ;;
    any|"") [[ -e "$path" ]] ;;
    *) [[ -e "$path" ]] ;;
  esac
}

available_disk_kib() {
  df -Pk "$ROOT_DIR" 2>/dev/null | awk 'NR==2 {print $4}'
}

format_kib_as_gib() {
  local kib="${1:-0}"
  awk -v kib="$kib" 'BEGIN { printf "%.1f GiB", kib / 1024 / 1024 }'
}

check_init_disk_space() {
  local required_gib="${1:-8}"
  local required_kib=$((required_gib * 1024 * 1024))
  local available_kib
  available_kib="$(available_disk_kib)"

  if [[ -z "$available_kib" || "$available_kib" == "0" ]]; then
    warn "nelze ověřit volné místo před init"
    return 0
  fi

  if [[ "$available_kib" -lt "$required_kib" ]]; then
    fail "doctor init potřebuje alespoň ${required_gib} GiB volného místa"
    hint "aktuálně dostupné: $(format_kib_as_gib "$available_kib")"
    hint "uvolni místo nebo spusť init na větším disku"
    return 2
  fi

  ok "volné místo pro init: $(format_kib_as_gib "$available_kib")"
}

submodule_has_delete_only_status() {
  local module_path="$1"
  local status_line
  local saw_line=0

  while IFS= read -r status_line; do
    [[ -z "$status_line" ]] && continue
    saw_line=1
    case "${status_line:0:2}" in
      " D"|"D "|"DD") ;;
      *) return 1 ;;
    esac
  done < <(git -C "${module_path}" status --porcelain 2>/dev/null || true)

  [[ "$saw_line" -eq 1 ]]
}

repair_empty_submodule_worktree() {
  local module="$1"
  local module_path="${ROOT_DIR}/${module}"

  if [[ ! -d "${module_path}" ]]; then
    return 1
  fi

  if [[ ! -d "${module_path}/.git" && ! -f "${module_path}/.git" ]]; then
    return 1
  fi

  if [[ -n "$(find "${module_path}" -mindepth 1 -maxdepth 1 ! -name '.git' -print -quit 2>/dev/null)" ]]; then
    return 1
  fi

  if ! submodule_has_delete_only_status "${module_path}"; then
    return 1
  fi

  git -C "${module_path}" restore --source=HEAD --staged --worktree . >/dev/null 2>&1 || return 1
  return 0
}

infer_person_from_pwd() {
  local pwd_abs
  pwd_abs="$(pwd -P)"
  if [[ "$pwd_abs" == "${ROOT_DIR}/company/colleagues/"* ]]; then
    sed -E "s#${ROOT_DIR}/company/colleagues/([^/]+).*#\1#" <<<"$pwd_abs"
  fi
}

env_bootstrap_dirs() {
  (
    cd "$ROOT_DIR" || return 0
    find modules -path '*/app*' -type f -name '.env.example' -not -path '*/node_modules/*' 2>/dev/null \
      | sed 's|/\.env\.example$||' \
      | sort -u
  )
}

dir_sync_preview() {
  local source="$1" target="$2"
  if ! command -v rsync >/dev/null 2>&1; then
    return 0
  fi

  rsync -an --exclude '.DS_Store' "${source}/" "${target}/" 2>/dev/null \
    | sed '/^sending incremental file list$/d;/^sent .* bytes.*$/d;/^total size is .*$/d;/^$/d'
}

check_launchpad_app_install() {
  local uname_s
  uname_s="$(uname -s)"

  if [[ "$uname_s" == "Linux" ]]; then
    header "Launchpad Linux launcher"
    local xdg_data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
    local xdg_bin_home="${XDG_BIN_HOME:-${HOME}/.local/bin}"
    local desktop_path="${xdg_data_home}/applications/agentmint-launchpad-gen2.desktop"
    local launcher_path="${xdg_bin_home}/agentmint-launchpad-gen2"
    if [[ -f "$desktop_path" ]]; then
      ok ".desktop entry nainstalovaný: ${desktop_path}"
    else
      warn ".desktop entry chybí: ${desktop_path}"
      hint "spusť 'company/scripts/doctor.sh install-launchpad'"
    fi
    if [[ -x "$launcher_path" ]]; then
      ok "launcher skript: ${launcher_path}"
    else
      warn "launcher skript chybí: ${launcher_path}"
      hint "spusť 'company/scripts/doctor.sh install-launchpad'"
    fi
    return 0
  fi

  if [[ "$uname_s" != "Darwin" ]]; then
    return 0
  fi

  header "Launchpad macOS app"

  local gen2_app="${HOME}/Applications/AgentMint Launchpad GEN2.app"
  local legacy_app="${HOME}/Applications/AgentMint Launchpad.app"

  if [[ -d "$gen2_app" ]]; then
    ok "GEN2 Launchpad app nainstalovaná: ${gen2_app}"
  else
    warn "GEN2 Launchpad app chybí: ${gen2_app}"
    hint "spusť 'company/scripts/doctor.sh install-launchpad'"
  fi

  if [[ -d "$legacy_app" ]]; then
    warn "legacy Launchpad app je stále nainstalovaná: ${legacy_app}"
    hint "odinstaluj starý bundle po ověření, že používáš GEN2"
  else
    ok "legacy Launchpad app není nainstalovaná"
  fi

  local dock_plist="${HOME}/Library/Preferences/com.apple.dock.plist"
  if [[ -f "$dock_plist" ]] && command -v plutil >/dev/null 2>&1; then
    local dock_dump
    dock_dump="$(plutil -p "$dock_plist" 2>/dev/null || true)"

    if grep -Fq "AgentMint Launchpad GEN2" <<<"$dock_dump"; then
      ok "Dock obsahuje AgentMint Launchpad GEN2"
    else
      warn "Dock neobsahuje AgentMint Launchpad GEN2"
      hint "spusť 'company/scripts/doctor.sh install-launchpad'"
    fi

    if grep -Fq "AgentMint Launchpad.app" <<<"$dock_dump"; then
      warn "Dock stále obsahuje legacy AgentMint Launchpad"
      hint "odeber starou Dock položku a nech jen GEN2"
    fi
  else
    warn "nelze ověřit Dock položku Launchpadu (chybí plist nebo plutil)"
  fi
}

dock_dump() {
  local dock_plist="${HOME}/Library/Preferences/com.apple.dock.plist"
  if [[ -f "$dock_plist" ]] && command -v plutil >/dev/null 2>&1; then
    plutil -p "$dock_plist" 2>/dev/null || true
  fi
}

dock_contains() {
  local needle="$1"
  local dump
  dump="$(dock_dump)"
  [[ -n "$dump" ]] && grep -Fq "$needle" <<<"$dump"
}

xml_escape() {
  sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\&apos;/g"
}

add_launchpad_to_dock() {
  local app_path="$1"

  if dock_contains "AgentMint Launchpad GEN2" || dock_contains "$app_path"; then
    ok "Dock už obsahuje AgentMint Launchpad GEN2"
    return 0
  fi

  if ! command -v defaults >/dev/null 2>&1; then
    warn "nelze upravit Dock (chybí defaults)"
    hint "přidej ${app_path} do Docku ručně"
    return 1
  fi

  local dock_entry
  local app_path_xml
  app_path_xml="$(printf '%s' "$app_path" | xml_escape)"
  dock_entry="$(cat <<EOF
<dict>
  <key>tile-data</key>
  <dict>
    <key>file-data</key>
    <dict>
      <key>_CFURLString</key>
      <string>${app_path_xml}</string>
      <key>_CFURLStringType</key>
      <integer>0</integer>
    </dict>
  </dict>
  <key>tile-type</key>
  <string>file-tile</string>
</dict>
EOF
)"

  if defaults write com.apple.dock persistent-apps -array-add "$dock_entry" >/dev/null 2>&1; then
    killall Dock >/dev/null 2>&1 || true
    ok "Dock doplněn o AgentMint Launchpad GEN2"
  else
    warn "nepodařilo se automaticky doplnit Dock"
    hint "přidej ${app_path} do Docku ručně"
    return 1
  fi
}

check_firebase_env_bootstrap() {
  header "Firebase env bootstrap"

  local env_total=0 env_missing=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    env_total=$((env_total+1))

    if [[ -f "${ROOT_DIR}/${app_dir}/.env.local" ]]; then
      ok "${app_dir}/.env.local existuje"
    else
      env_missing=$((env_missing+1))
      warn "${app_dir}/.env.local chybí"
      hint_classified "agent-safe" "local-only" "doctor check --fix vytvoří ${app_dir}/.env.local z .env.example, pokud cílový soubor pořád neexistuje"
    fi
  done < <(env_bootstrap_dirs)

  if [[ "$env_total" -eq 0 ]]; then
    printf '  [info] žádný app dir s .env.example\n'
  elif [[ "$env_missing" -eq 0 ]]; then
    ok "všech ${env_total} app dirů s .env.example má i .env.local"
  fi
}

project_module_root() {
  local app_dir="$1"
  case "$app_dir" in
    modules/*/*)
      awk -F'/' '{print $1"/"$2}' <<<"$app_dir"
      ;;
  esac
}

workspace_path_is_ignored() {
  local rel_path="$1"
  local module_root
  module_root="$(project_module_root "$rel_path")"
  if [[ -n "$module_root" && "$(module_state "$module_root")" == "available" ]]; then
    local module_rel="${rel_path#${module_root}/}"
    git -C "${ROOT_DIR}/${module_root}" check-ignore -q -- "$module_rel"
    return $?
  fi
  git -C "$ROOT_DIR" check-ignore -q -- "$rel_path"
}


is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

homebrew_prefix() {
  if command -v brew >/dev/null 2>&1; then
    brew --prefix 2>/dev/null || true
    return 0
  fi
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    printf '/opt/homebrew\n'
    return 0
  fi
  if [[ -x "/usr/local/bin/brew" ]]; then
    printf '/usr/local\n'
    return 0
  fi
}

ensure_homebrew_shellenv() {
  local prefix
  prefix="$(homebrew_prefix | head -n 1)"
  [[ -n "$prefix" ]] || return 1

  case ":$PATH:" in
    *":${prefix}/bin:"*) ;;
    *) export PATH="${prefix}/bin:${prefix}/sbin:${PATH}" ;;
  esac
}

zsh_tool_path() {
  local mode="$1"
  local tool="$2"
  local escaped_tool
  printf -v escaped_tool '%q' "$tool"
  /bin/zsh "$mode" "path=\$(command -v ${escaped_tool} 2>/dev/null || true); if [[ -n \"\$path\" ]]; then printf '__workspace_doctor_path__%s\n' \"\$path\"; fi" 2>/dev/null \
    | sed -n 's/^__workspace_doctor_path__//p' \
    | tail -n 1 \
    || true
}

login_shell_tool_path() {
  local tool="$1"
  if is_macos && [[ -x "/bin/zsh" ]]; then
    local path
    path="$(zsh_tool_path "-lc" "$tool")"
    if [[ -z "$path" && "$tool" == "bun" ]]; then
      path="$(zsh_tool_path "-lic" "$tool")"
    fi
    printf '%s\n' "$path"
  else
    command -v "$tool" 2>/dev/null || true
  fi
}

brew_formula_for_tool() {
  case "$1" in
    git) echo "git" ;;
    gh) echo "gh" ;;
    jq) echo "jq" ;;
    node) echo "node" ;;
    bun) echo "bun" ;;
    codex) echo "codex" ;;
    *) echo "$1" ;;
  esac
}

brew_formula_installed() {
  local formula="$1"
  command -v brew >/dev/null 2>&1 || return 1
  brew list --formula --versions "$formula" >/dev/null 2>&1 \
    || brew list --cask --versions "$formula" >/dev/null 2>&1
}

brew_formula_outdated() {
  local formula="$1"
  command -v brew >/dev/null 2>&1 || return 1
  brew outdated --quiet "$formula" 2>/dev/null | grep -Fxq "$formula" \
    || brew outdated --cask --quiet "$formula" 2>/dev/null | grep -Fxq "$formula"
}

append_homebrew_shellenv_to_file() {
  local file="$1"
  local prefix="$2"
  [[ -n "$prefix" ]] || return 1
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -Fq "${prefix}/bin/brew shellenv" "$file" 2>/dev/null; then
    return 0
  fi
  cat >>"$file" <<EOF

# AgentMint Workspace toolchain (managed by doctor)
if [ -x "${prefix}/bin/brew" ]; then
  eval "\$(${prefix}/bin/brew shellenv)"
fi
EOF
}

repair_brew_shell_path_local() {
  local prefix
  prefix="$(homebrew_prefix | head -n 1)"
  [[ -n "$prefix" ]] || return 1
  append_homebrew_shellenv_to_file "${HOME}/.zprofile" "$prefix"
  append_homebrew_shellenv_to_file "${HOME}/.zshrc" "$prefix"
  export PATH="${prefix}/bin:${prefix}/sbin:${PATH}"
}

check_required_tool() {
  local tool="$1"
  local formula
  formula="$(brew_formula_for_tool "$tool")"
  local path login_path version
  path="$(command -v "$tool" 2>/dev/null || true)"
  login_path="$(login_shell_tool_path "$tool")"

  if [[ -n "$path" && -n "$login_path" ]]; then
    version="$($tool --version 2>&1 | head -n 1 || true)"
    ok "$tool dostupný (${path}${version:+, ${version}})"
  elif [[ -n "$path" ]]; then
    warn "$tool je dostupný v aktuálním PATH, ale ne v novém uživatelském shellu"
    if [[ "$tool" == "bun" ]]; then
      hint_classified "user-action" "local-only" "zkontroluj, že ~/.zshrc exportuje BUN_INSTALL a ~/.bun/bin; potom otevři nový Terminál"
    else
      hint_classified "agent-safe" "local-only" "spusť 'doctor check --fix'; Doctor doplní Homebrew shellenv do ~/.zprofile a ~/.zshrc"
    fi
  else
    warn "$tool není v PATH"
    if is_macos && command -v brew >/dev/null 2>&1; then
      if [[ "$tool" == "bun" ]]; then
        hint_classified "user-action" "local-only" "nainstaluj Bun podle company/scripts/doctor/fixes/tooling-missing.md"
      else
        hint_classified "agent-safe" "local-only" "spusť 'doctor check --fix' nebo ručně 'brew install ${formula}'"
      fi
    else
      hint_classified "user-action" "local-only" "nainstaluj ${tool}; na macOS používej Homebrew"
    fi
  fi

  if [[ "$tool" == "bun" ]]; then
    return 0
  fi

  if is_macos && command -v brew >/dev/null 2>&1; then
    if brew_formula_installed "$formula"; then
      if [[ "$tool" == "codex" ]] && brew_formula_outdated "$formula"; then
        warn "codex má v Homebrew dostupnou novější verzi"
        hint_classified "agent-safe" "local-only" "spusť 'doctor check --fix' nebo ručně 'brew upgrade codex'"
      else
        ok "${tool} je spravovaný přes Homebrew (${formula})"
      fi
    else
      warn "${tool} není spravovaný přes Homebrew (${formula})"
      hint_classified "agent-safe" "local-only" "spusť 'doctor check --fix'; Doctor použije 'brew install ${formula}'"
    fi
  fi
}

repair_coworker_tooling_local() {
  header "Local repair: coworker-machine tooling"

  if ! is_macos; then
    printf '  [skip] automatický Homebrew repair je zatím jen pro macOS\n'
    return 0
  fi

  ensure_homebrew_shellenv || true
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew není dostupný"
    hint_classified "user-action" "local-only" "nainstaluj Homebrew a spusť 'doctor check --fix' znovu"
    return 0
  fi

  repair_brew_shell_path_local || true

  local tool formula
  for tool in git gh jq node bun codex; do
    formula="$(brew_formula_for_tool "$tool")"
    if [[ "$tool" == "bun" ]]; then
      if command -v bun >/dev/null 2>&1; then
        continue
      fi
      warn "bun není v PATH"
      hint_classified "user-action" "local-only" "nainstaluj Bun podle company/scripts/doctor/fixes/tooling-missing.md"
      continue
    fi
    if [[ "$tool" == "jq" || "$tool" == "node" ]] && command -v "$tool" >/dev/null 2>&1; then
      continue
    fi
    if ! command -v "$tool" >/dev/null 2>&1 || ! brew_formula_installed "$formula"; then
      printf '  → brew install %s\n' "$formula"
      if brew install "$formula" >/dev/null 2>&1; then
        ok "${tool} nainstalovaný přes Homebrew"
      else
        warn "brew install ${formula} selhal"
        hint_classified "user-action" "local-only" "zkus ručně: brew install ${formula}"
      fi
    fi
  done

  if brew_formula_installed codex && brew_formula_outdated codex; then
    printf '  → brew upgrade codex\n'
    if brew upgrade codex >/dev/null 2>&1; then
      ok "codex aktualizovaný přes Homebrew"
    else
      warn "brew upgrade codex selhal"
      hint_classified "user-action" "local-only" "zkus ručně: brew upgrade codex"
    fi
  fi

  local codex_login
  codex_login="$(login_shell_tool_path codex)"
  if [[ -n "$codex_login" ]]; then
    ok "codex je dostupný i v novém shellu (${codex_login})"
  else
    warn "codex pořád není dostupný v novém shellu"
    hint_classified "user-action" "local-only" "otevři nový Terminál a ověř 'command -v codex'; případně zkontroluj ~/.zprofile a ~/.zshrc"
  fi
}

repair_missing_env_locals() {
  header "Local repair: .env.local"

  local total=0 created=0 skipped=0 not_ignored=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    total=$((total+1))

    local target="${ROOT_DIR}/${app_dir}/.env.local"
    local source="${ROOT_DIR}/${app_dir}/.env.example"
    local module_root
    module_root="$(project_module_root "$app_dir")"
    if [[ -n "$module_root" && "$(submodule_dirty "$module_root")" == "dirty" ]]; then
      warn "${app_dir}/.env.local chybí, ale nested repo ${module_root} je dirty — nevytvářím"
      hint_classified "needs-approval" "git-sync" "nejdřív review lokálních změn v ${module_root}; repair-local dirty nested repo nikdy neupravuje"
      skipped=$((skipped+1))
      continue
    fi

    if [[ -f "$target" ]]; then
      printf '  [skip] %s/.env.local už existuje — nepřepisuji\n' "$app_dir"
      skipped=$((skipped+1))
      continue
    fi

    if cp "$source" "$target"; then
      ok "${app_dir}/.env.local vytvořeno z .env.example"
      created=$((created+1))
      if workspace_path_is_ignored "${app_dir}/.env.local"; then
        ok "${app_dir}/.env.local je ignorovaný Gitem"
      else
        not_ignored=$((not_ignored+1))
        warn "${app_dir}/.env.local není ignorovaný Gitem"
        hint_classified "user-action" "git-sync" "zkontroluj .gitignore v příslušném repu; .env.local nesmí skončit v commitu"
      fi
    else
      warn "${app_dir}/.env.local se nepodařilo vytvořit"
      hint_classified "user-action" "local-only" "zkontroluj práva k adresáři ${app_dir}"
    fi
  done < <(env_bootstrap_dirs)

  if [[ "$total" -eq 0 ]]; then
    printf '  [info] žádný app dir s .env.example\n'
  else
    printf '\n  .env.local repair: %d vytvořeno, %d ponecháno, %d není ignorováno Gitem\n' \
      "$created" "$skipped" "$not_ignored"
  fi
}

repair_node_deps_local() {
  header "Local repair: Node dependencies"

  if ! command -v bun >/dev/null 2>&1; then
    warn "bun není v PATH — nemůžu opravit Node dependencies"
    hint_classified "user-action" "local-only" "nainstaluj bun a spusť doctor check --fix znovu"
    return 0
  fi

  local total=0 repaired=0 skipped=0 failed=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    total=$((total+1))

    local health module_root
    health="$(dep_dir_health "$app_dir")"
    if [[ "$health" == "ok" ]]; then
      printf '  [skip] %s (závislosti vypadají zdravě)\n' "$app_dir"
      skipped=$((skipped+1))
      continue
    fi

    module_root="$(project_module_root "$app_dir")"
    if [[ -n "$module_root" && "$(submodule_dirty "$module_root")" == "dirty" ]]; then
      warn "${app_dir} — nested repo ${module_root} je dirty, lokální repair do něj nesahá"
      hint_classified "needs-approval" "git-sync" "nejdřív review lokálních změn v ${module_root}, potom spusť doctor check --fix znovu"
      skipped=$((skipped+1))
      continue
    fi

    case "$health" in
      missing_node_modules|missing_package:*)
        printf '  → %s (%s)\n' "$app_dir" "$(dep_dir_health_message "$app_dir" "$health")"
        if (cd "${ROOT_DIR}/${app_dir}" && bun install --frozen-lockfile --silent >/dev/null 2>&1); then
          if [[ "$(dep_dir_health "$app_dir")" == "ok" ]]; then
            ok "${app_dir} opraveno"
            repaired=$((repaired+1))
          else
            warn "${app_dir} — instalace doběhla, ale re-check pořád není čistý"
            hint_classified "user-action" "local-only" "spusť doctor install-deps pro cílený reinstall a finální deps-status"
            failed=$((failed+1))
          fi
        else
          warn "${app_dir} — frozen bun install selhal"
          hint_classified "user-action" "local-only" "spusť doctor install-deps; check --fix nepoužije nefrozen install, aby neměnil lockfile"
          failed=$((failed+1))
        fi
        ;;
      lockfile_out_of_sync)
        warn "${app_dir} — package.json / bun.lock nejsou synchronní"
        hint_classified "needs-approval" "git-sync" "spusť doctor install-deps po review; může změnit lockfile"
        skipped=$((skipped+1))
        ;;
      *)
        warn "${app_dir} — $(dep_dir_health_message "$app_dir" "$health")"
        hint_classified "user-action" "local-only" "zkontroluj projekt ručně nebo spusť doctor install-deps"
        skipped=$((skipped+1))
        ;;
    esac
  done < <(list_node_project_dirs)

  printf '\n  Dependency local repair: %d projektů, %d opraveno, %d přeskočeno, %d zůstalo rozbitých\n' \
    "$total" "$repaired" "$skipped" "$failed"
}

repair_detached_submodules_local() {
  header "Local repair: detached nested repo modules"

  local total=0 fixed=0 skipped=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      modules/monorepo|modules/firmware)
        continue
        ;;
    esac

    [[ "$(module_state "$path")" == "available" ]] || continue
    [[ "$(submodule_branch "$path")" == "detached" ]] || continue
    total=$((total+1))

    if [[ "$(submodule_dirty "$path")" == "dirty" ]]; then
      warn "${path}: detached HEAD, ale nested repo je dirty — nepřepínám"
      hint_classified "needs-approval" "git-sync" "nejdřív review lokálních změn v ${path}; doctor check --fix dirty nested repo nikdy neupravuje"
      skipped=$((skipped+1))
      continue
    fi

    if safe_checkout_detached_submodule "$path"; then
      fixed=$((fixed+1))
    else
      skipped=$((skipped+1))
    fi
  done < <(gitmodule_paths)

  if [[ "$total" -eq 0 ]]; then
    ok "žádný běžný clean nested repo modul není v detached HEAD"
  else
    printf '\n  Detached repair: %d nalezeno, %d přepnuto, %d přeskočeno\n' \
      "$total" "$fixed" "$skipped"
  fi
}

check_person_overlay_bootstrap() {
  local person="$1"
  [[ -z "$person" ]] && return 0

  local person_dir="${ROOT_DIR}/company/colleagues/${person}"
  local manifest_path="${person_dir}/doctor.manifest.json"

  header "Person overlay bootstrap (${person})"

  if [[ ! -d "$person_dir" ]]; then
    warn "person overlay ${person_dir} neexistuje"
    return 0
  fi

  if [[ ! -f "$manifest_path" ]]; then
    warn "${manifest_path} neexistuje"
    hint "přidej person-specific doctor manifest pro migraci a lokální setup"
    return 0
  fi

  ok "doctor manifest načten: ${manifest_path}"

  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    local label rel_path kind abs_path
    label="$(jq -r '.label // .path' <<<"$entry")"
    rel_path="$(jq -r '.path' <<<"$entry")"
    kind="$(jq -r '.type // "any"' <<<"$entry")"
    abs_path="${person_dir}/${rel_path}"

    if path_matches_type "$abs_path" "$kind"; then
      ok "${label}: ${rel_path}"
    else
      warn "${label}: chybí ${rel_path}"
    fi
  done < <(jq -c '.required_paths[]?' "$manifest_path")

  header "GEN1 migration audit (${person})"

  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    local label source target kind required policy reason diff_preview
    label="$(jq -r '.label // "migration"' <<<"$entry")"
    source="$(expand_doctor_path "$(jq -r '.source // empty' <<<"$entry")")"
    policy="$(jq -r '.policy // empty' <<<"$entry")"
    reason="$(jq -r '.reason // empty' <<<"$entry")"
    required="$(jq -r '.required // false' <<<"$entry")"

    if [[ "$policy" == "skip" ]]; then
      if [[ -e "$source" ]]; then
        ok "${label}: záměrně neportováno (${reason})"
      else
        ok "${label}: source neexistuje a je záměrně neportovaný (${reason})"
      fi
      continue
    fi

    kind="$(jq -r '.type // "any"' <<<"$entry")"
    target="$(jq -r '.target // empty' <<<"$entry")"
    if [[ "$target" != /* ]]; then
      target="${person_dir}/${target}"
    fi
    target="$(expand_doctor_path "$target")"

    if [[ ! -e "$source" ]]; then
      if [[ "$required" == "true" ]]; then
        warn "${label}: source ${source} chybí, nelze ověřit migraci"
      else
        ok "${label}: source ${source} neexistuje, nic k migraci"
      fi
      continue
    fi

    if ! path_matches_type "$target" "$kind"; then
      warn "${label}: target ${target} chybí"
      continue
    fi

    case "$kind" in
      file)
        if cmp -s "$source" "$target"; then
          ok "${label}: soubor je přenesený"
        else
          warn "${label}: target se liší od source"
        fi
        ;;
      dir)
        diff_preview="$(dir_sync_preview "$source" "$target" | head -n 5)"
        if [[ -z "$diff_preview" ]]; then
          ok "${label}: adresář je přenesený"
        else
          warn "${label}: target není plně synchronní se source"
          while IFS= read -r line; do
            [[ -n "$line" ]] && hint "$line"
          done <<<"$diff_preview"
        fi
        ;;
      *)
        ok "${label}: source i target existují"
        ;;
    esac
  done < <(jq -c '.legacy_migrations[]?' "$manifest_path")
}

ensure_default_tool_paths() {
  ensure_homebrew_shellenv || true

  if ! command -v bun >/dev/null 2>&1 && [[ -x "${HOME}/.bun/bin/bun" ]]; then
    export BUN_INSTALL="${BUN_INSTALL:-${HOME}/.bun}"
    export PATH="${BUN_INSTALL}/bin:${PATH}"
  fi
}

# --- Manifest readers ---

manifest_submodule_paths() {
  jq -r '.module_slots[].path' "$MANIFEST"
}

manifest_module_url() {
  local path="$1"
  jq -r --arg p "$path" '.module_slots[] | select(.path == $p) | .git.url // empty' "$MANIFEST"
}

manifest_module_branch() {
  local path="$1"
  jq -r --arg p "$path" '.module_slots[] | select(.path == $p) | .git.branch // "main"' "$MANIFEST"
}

manifest_top_level_submodule_paths() {
  manifest_submodule_paths | awk -F'/' 'NF<=2'
}

manifest_nested_submodule_paths() {
  manifest_submodule_paths | awk -F'/' 'NF>2'
}

current_manifest_platform() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "linux" ;;
  esac
}

manifest_slot_supports_current_platform() {
  local path="$1"
  local platform
  platform="$(current_manifest_platform)"
  jq -e --arg p "$path" --arg platform "$platform" '
    .module_slots[]
    | select(.path == $p)
    | (.platforms // ["macos", "windows"])
    | index($platform) != null
  ' "$MANIFEST" >/dev/null
}

gitmodule_paths() {
  jq -r '.module_slots[] | select(.git.url? and .git.url != "") | .path' "$MANIFEST"
}

module_state() {
  # Vrátí: available | missing_access | planned_slot
  local path="$1"
  if [[ -z "$(manifest_module_url "$path")" ]]; then
    echo "planned_slot"
    return
  fi
  if [[ -d "${ROOT_DIR}/${path}/.git" ]] || [[ -f "${ROOT_DIR}/${path}/.git" ]]; then
    echo "available"
  else
    echo "missing_access"
  fi
}

submodule_dirty() {
  # Vrací "dirty" / "clean" / "-" pro modul.
  local path="$1"
  if [[ ! -d "${ROOT_DIR}/${path}" ]]; then
    echo "-"
    return
  fi
  if [[ -n "$(git -C "${ROOT_DIR}/${path}" status --porcelain 2>/dev/null)" ]]; then
    echo "dirty"
  else
    echo "clean"
  fi
}

submodule_branch() {
  local path="$1"
  if [[ ! -d "${ROOT_DIR}/${path}/.git" && ! -f "${ROOT_DIR}/${path}/.git" ]]; then
    echo "-"
    return
  fi
  local branch
  branch="$(git -C "${ROOT_DIR}/${path}" branch --show-current 2>/dev/null || true)"
  if [[ -n "$branch" ]]; then
    echo "$branch"
  else
    echo "detached"
  fi
}

submodule_expected_branch() {
  local path="$1"
  manifest_module_branch "$path"
}

ensure_submodule_expected_branch() {
  local path="$1"
  local mode="${2:-remote}"
  local state branch expected

  state="$(module_state "$path")"
  [[ "$state" == "available" ]] || return 0

  branch="$(submodule_branch "$path")"
  expected="$(submodule_expected_branch "$path")"

  if [[ "$branch" == "$expected" ]]; then
    return 0
  fi

  if [[ "$(submodule_dirty "$path")" == "dirty" ]]; then
    warn "$path je dirty — nepřepínám větev během init/sync"
    return 1
  fi

  if [[ "$mode" == "preserve-head" && "$branch" == "detached" ]]; then
    if git -C "${ROOT_DIR}/${path}" checkout -B "${expected}" >/dev/null 2>&1; then
      if git -C "${ROOT_DIR}/${path}" rev-parse --verify --quiet "refs/remotes/origin/${expected}" >/dev/null 2>&1; then
        git -C "${ROOT_DIR}/${path}" branch --set-upstream-to "origin/${expected}" "${expected}" >/dev/null 2>&1 || true
      fi
      ok "$path přepnuto z detached HEAD na ${expected}"
      return 0
    fi
  fi

  if git -C "${ROOT_DIR}/${path}" rev-parse --verify --quiet "refs/heads/${expected}" >/dev/null 2>&1; then
    if git -C "${ROOT_DIR}/${path}" checkout "${expected}" >/dev/null 2>&1; then
      if git -C "${ROOT_DIR}/${path}" rev-parse --verify --quiet "refs/remotes/origin/${expected}" >/dev/null 2>&1; then
        git -C "${ROOT_DIR}/${path}" branch --set-upstream-to "origin/${expected}" "${expected}" >/dev/null 2>&1 || true
      fi
      if [[ "$branch" == "detached" ]]; then
        ok "$path přepnuto z detached HEAD na ${expected}"
      else
        ok "$path přepnuto z ${branch} na ${expected}"
      fi
      return 0
    fi
  fi

  if git -C "${ROOT_DIR}/${path}" rev-parse --verify --quiet "refs/remotes/origin/${expected}" >/dev/null 2>&1; then
    if git -C "${ROOT_DIR}/${path}" checkout -B "${expected}" --track "origin/${expected}" >/dev/null 2>&1 \
      || git -C "${ROOT_DIR}/${path}" checkout -B "${expected}" "origin/${expected}" >/dev/null 2>&1; then
      if [[ "$branch" == "detached" ]]; then
        ok "$path přepnuto z detached HEAD na ${expected}"
      else
        ok "$path přepnuto z ${branch} na ${expected}"
      fi
      return 0
    fi
  fi

  warn "$path: nepodařilo se přepnout na ${expected}"
  return 1
}

safe_checkout_detached_submodule() {
  local path="$1"
  local expected head local_head remote_head

  expected="$(submodule_expected_branch "$path")"
  head="$(git -C "${ROOT_DIR}/${path}" rev-parse HEAD 2>/dev/null || true)"
  [[ -n "$head" ]] || return 1

  local_head="$(git -C "${ROOT_DIR}/${path}" rev-parse "refs/heads/${expected}" 2>/dev/null || true)"
  remote_head="$(git -C "${ROOT_DIR}/${path}" rev-parse "refs/remotes/origin/${expected}" 2>/dev/null || true)"

  if [[ -n "$local_head" && "$head" == "$local_head" ]]; then
    if git -C "${ROOT_DIR}/${path}" checkout "${expected}" >/dev/null 2>&1; then
      ok "${path} přepnuto z detached HEAD na ${expected} (HEAD beze změny)"
      return 0
    fi
  fi

  if [[ -n "$remote_head" && "$head" == "$remote_head" ]]; then
    if git -C "${ROOT_DIR}/${path}" checkout -B "${expected}" "origin/${expected}" >/dev/null 2>&1; then
      git -C "${ROOT_DIR}/${path}" branch --set-upstream-to "origin/${expected}" "${expected}" >/dev/null 2>&1 || true
      ok "${path} přepnuto z detached HEAD na ${expected} (HEAD odpovídal origin/${expected})"
      return 0
    fi
  fi

  warn "${path}: detached HEAD není na tipu ${expected} ani origin/${expected} — nepřepínám"
  hint_classified "needs-approval" "git-sync" "zkontroluj ${path} ručně; automatický repair nesmí posunout obsah nested repo modulu"
  return 1
}

configure_manifest_fork_submodules() {
  local fork_path configured=0 skipped=0

  while IFS= read -r fork_path; do
    [[ -z "$fork_path" ]] && continue

    if [[ ! -d "${ROOT_DIR}/${fork_path}" ]] || \
       { [[ ! -d "${ROOT_DIR}/${fork_path}/.git" ]] && [[ ! -f "${ROOT_DIR}/${fork_path}/.git" ]]; }; then
      skipped=$((skipped+1))
      continue
    fi

    local mirror source parent_name current_upstream current_parent
    mirror="$(jq -r --arg p "$fork_path" '.module_slots[] | select(.path==$p) | .fork_upstream.mirror' "$MANIFEST")"
    source="$(jq -r --arg p "$fork_path" '.module_slots[] | select(.path==$p) | .fork_upstream.source' "$MANIFEST")"
    parent_name="$(basename -s .git "$mirror")"

    current_upstream="$(git -C "${ROOT_DIR}/${fork_path}" remote get-url upstream 2>/dev/null || echo "")"
    if [[ "$current_upstream" != "$mirror" ]]; then
      if [[ -n "$current_upstream" ]]; then
        git -C "${ROOT_DIR}/${fork_path}" remote set-url upstream "$mirror" >/dev/null
      else
        git -C "${ROOT_DIR}/${fork_path}" remote add upstream "$mirror" >/dev/null
      fi
    fi

    current_parent="$(git -C "${ROOT_DIR}/${fork_path}" remote get-url "${parent_name}-origin" 2>/dev/null || echo "")"
    if [[ "$current_parent" != "$source" ]]; then
      if [[ -n "$current_parent" ]]; then
        git -C "${ROOT_DIR}/${fork_path}" remote set-url "${parent_name}-origin" "$source" >/dev/null
      else
        git -C "${ROOT_DIR}/${fork_path}" remote add "${parent_name}-origin" "$source" >/dev/null
      fi
    fi

    git -C "${ROOT_DIR}/${fork_path}" config rerere.enabled true >/dev/null
    ok "${fork_path}: fork remotes + rerere configured"
    configured=$((configured+1))
  done < <(jq -r '.module_slots[] | select(.fork_upstream != null) | .path' "$MANIFEST")

  if [[ "$configured" -eq 0 && "$skipped" -eq 0 ]]; then
    printf '  [info] žádný fork modul v manifestu\n'
  fi
}

repo_non_main_branch_reason() {
  local path="$1"
  local branch="${2:-}"
  case "$path" in
    modules/monorepo)
      printf 'task-driven PR workflow'
      return 0
      ;;
    modules/firmware)
      if [[ -z "$branch" || "$branch" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9][A-Za-z0-9._-]*)?$ ]]; then
        printf 'firmware version branch workflow, např. 1.2.0 nebo 2.0.0-dev'
        return 0
      fi
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

repo_allows_non_main_branch() {
  repo_non_main_branch_reason "$1" "${2:-}" >/dev/null
}

# --- App dirs (pro dep checks / install-deps) ---

# Najde všechny runnable app adresáře se svým package.json.
# Pokrývá top-level in-tree appky a nested repo app patterny z manifestu:
#   design-system/app/package.json
#   guide/app/package.json
#   mission-control/app/v1/package.json
#   <nested-repo>/app/v1/package.json
#   <nested-repo>/app/package.json
# Starší modulové příklady:
#   modules/<id>/app/v1/package.json
#   modules/<id>/app/package.json            (např. modules/website/app)
# Nezahrnuje vnořené nebo non-app složky (editor/, studio/, scripts/ atd.).
# Vrací relativní cesty (vůči ROOT_DIR), seřazené, unikátní.
list_manifest_app_dirs() {
  local repo candidate
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    for candidate in "${repo}/app" "${repo}/app/v1"; do
      if [[ -f "${ROOT_DIR}/${candidate}/package.json" ]]; then
        printf '%s\n' "$candidate"
      fi
    done
  done < <(gitmodule_paths)
}

dep_module_target_matches() {
  local app_dir="$1"
  local target="$2"
  [[ -z "$target" ]] && return 0

  local normalized="${target%/}"
  local target_paths=("$normalized")
  if [[ "$normalized" != */* ]]; then
    target_paths+=("modules/${normalized}")
  fi

  local target_path
  for target_path in "${target_paths[@]}"; do
    if [[ "$app_dir" == "${target_path}/app" || "$app_dir" == "${target_path}/app/"* ]]; then
      return 0
    fi
  done
  return 1
}

list_node_project_dirs() {
  (
    cd "$ROOT_DIR" || return 0
    [[ -f "design-system/app/package.json" ]] && echo "design-system/app"
    [[ -f "guide/app/package.json" ]] && echo "guide/app"
    [[ -f "launchpad/app/v1/package.json" ]] && echo "launchpad/app/v1"
    [[ -f "launchpad/contracts/package.json" ]] && echo "launchpad/contracts"
    list_manifest_app_dirs
  ) | sort -u
}

declared_package_names() {
  local dir="$1"
  jq -r '((.dependencies // {}) + (.devDependencies // {})) | keys[]?' \
    "${ROOT_DIR}/${dir}/package.json" 2>/dev/null
}

dep_dir_health() {
  local dir="$1"
  if [[ ! -f "${ROOT_DIR}/${dir}/package.json" ]]; then
    echo "missing_package_json"
    return
  fi

  if [[ ! -d "${ROOT_DIR}/${dir}/node_modules" ]]; then
    echo "missing_node_modules"
    return
  fi

  local dep
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue
    if [[ ! -f "${ROOT_DIR}/${dir}/node_modules/${dep}/package.json" ]]; then
      echo "missing_package:${dep}"
      return
    fi
  done < <(declared_package_names "$dir")

  if command -v bun >/dev/null 2>&1; then
    if ! (cd "${ROOT_DIR}/${dir}" && bun install --frozen-lockfile --dry-run --silent >/dev/null 2>&1); then
      echo "lockfile_out_of_sync"
      return
    fi
  fi

  echo "ok"
}

dep_dir_needs_install() {
  local dir="$1"
  [[ "$(dep_dir_health "$dir")" != "ok" ]]
}

dep_dir_health_message() {
  local dir="$1"
  local health="$2"
  case "$health" in
    ok) echo "OK" ;;
    missing_package_json) echo "chybí package.json" ;;
    missing_node_modules) echo "chybí node_modules" ;;
    lockfile_out_of_sync) echo "package.json / bun.lock nejsou synchronní" ;;
    missing_package:*)
      echo "chybí balíček ${health#missing_package:} v node_modules"
      ;;
    *)
      echo "$health"
      ;;
  esac
}

# Vrátí "ahead<TAB>behind" vůči origin/main. Pro moduly, co nejsou
# git repo / nemají origin/main ref vrátí "- -".
module_ahead_behind() {
  local path="$1"
  if [[ ! -d "${ROOT_DIR}/${path}/.git" && ! -f "${ROOT_DIR}/${path}/.git" ]]; then
    echo "- -"
    return
  fi
  local branch ref counts
  branch="$(git -C "${ROOT_DIR}/${path}" branch --show-current 2>/dev/null || echo "")"
  ref="origin/${branch:-main}"
  # git rev-list output: "<behind>\t<ahead>" relativně k ${ref}...HEAD
  counts="$(git -C "${ROOT_DIR}/${path}" rev-list --left-right --count "${ref}...HEAD" 2>/dev/null || echo "")"
  if [[ -z "$counts" ]]; then
    echo "- -"
    return
  fi
  # Reorder do "ahead<TAB>behind" pro konzistenci (git vrací behind první).
  local behind ahead
  behind="$(awk '{print $1}' <<<"$counts")"
  ahead="$(awk '{print $2}' <<<"$counts")"
  printf '%s\t%s\n' "${ahead:-0}" "${behind:-0}"
}

is_fork_module() {
  # Vrátí 0 (true), pokud má modul v manifestu pole fork_upstream.
  local path="$1"
  local fork
  fork="$(jq -r --arg p "$path" \
    '.module_slots[] | select(.path==$p) | .fork_upstream // empty' \
    "$MANIFEST" 2>/dev/null)"
  [[ -n "$fork" ]]
}

# --- Subcommand: status ---

cmd_status() {
  if has_help_arg "$@"; then
    print_status_usage
    return 0
  fi
  if [[ "$#" -gt 0 ]]; then
    fail "doctor status nezná argument: $1"
    hint "spusť 'doctor status --help'"
    return 2
  fi

  header "Super-repo"
  local super_branch super_dirty super_remote super_ab super_ahead super_behind
  super_branch="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || echo "detached")"
  super_dirty="$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  super_remote="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || echo "(no origin)")"
  super_ab="$(module_ahead_behind ".")"
  super_ahead="$(awk '{print $1}' <<<"$super_ab")"
  super_behind="$(awk '{print $2}' <<<"$super_ab")"

  printf '  branch:   %s\n' "$super_branch"
  printf '  dirty:    %s soubor(ů)\n' "$super_dirty"
  printf '  remote:   %s\n' "$super_remote"
  if [[ "$super_ahead" != "-" && "$super_behind" != "-" ]]; then
    printf '  sync:     ↑%s ↓%s vůči origin/%s\n' \
      "${super_ahead:-0}" "${super_behind:-0}" "${super_branch:-main}"
  fi

  header "Moduly (podle manifestu)"
  local total=0 avail=0 missing=0 planned=0 dirty=0
  while IFS= read -r path; do
    total=$((total+1))
    local state
    state="$(module_state "$path")"
    local dirty_flag branch_flag
    dirty_flag="$(submodule_dirty "$path")"
    branch_flag="$(submodule_branch "$path")"

    local fork_tag=""
    is_fork_module "$path" && fork_tag=", fork"

    case "$state" in
      available)
        avail=$((avail+1))
        if [[ "$dirty_flag" == "dirty" ]]; then
          dirty=$((dirty+1))
          warn "${path}  (branch: ${branch_flag}${fork_tag}, DIRTY)"
        else
          ok "${path}  (branch: ${branch_flag}${fork_tag})"
        fi
        ;;
      missing_access)
        missing=$((missing+1))
        warn "${path}  (missing_access — SSH přístup nebo spusť 'doctor sync')"
        ;;
      planned_slot)
        planned=$((planned+1))
        printf '  [planned] %s\n' "$path"
        ;;
    esac
  done < <(manifest_submodule_paths)

  printf '\n  Celkem: %d modulů — %d available, %d missing_access, %d planned, %d dirty\n' \
    "$total" "$avail" "$missing" "$planned" "$dirty"
}

# --- Template placeholder check ---

_check_template_placeholders() {
  header "Template placeholders"

  local grep_output
  grep_output="$(grep -rn \
    --exclude-dir='.git' \
    --exclude-dir='node_modules' \
    --exclude-dir='target' \
    --exclude-dir='dist' \
    --exclude='TEMPLATE.md' \
    --exclude='TEMPLATE_CHANGELOG.md' \
    --exclude='TEMPLATE_VERSION' \
    -E '<VYPLNIT_[A-Z_]+>' "$ROOT_DIR" 2>/dev/null || true)"

  if [[ -z "$grep_output" ]]; then
    ok "žádné <VYPLNIT_*> placeholdery nezbývají — production-ready"
    return 0
  fi

  local count_total count_files
  count_total="$(printf '%s\n' "$grep_output" | wc -l | tr -d ' ')"
  count_files="$(printf '%s\n' "$grep_output" \
    | awk -F':' '{print $1}' | sort -u | wc -l | tr -d ' ')"

  warn "zbývá ${count_total} výskyt(ů) <VYPLNIT_*> ve ${count_files} soubor(ech)"

  local current_file=""
  local rel_path rest filepath linenum placeholder
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    filepath="${line%%:*}"
    rest="${line#*:}"
    linenum="${rest%%:*}"
    rel_path="${filepath#"$ROOT_DIR"/}"
    if [[ "$rel_path" != "$current_file" ]]; then
      current_file="$rel_path"
      printf '    %s\n' "$rel_path"
    fi
    placeholder="$(printf '%s' "$line" \
      | grep -oE '<VYPLNIT_[A-Z_]+>' | head -n 1)"
    printf '       L%-4s  %s\n' "$linenum" "$placeholder"
  done <<<"$grep_output"

  hint "vyplň placeholdery a spusť 'doctor check --template-placeholders' znovu"
  hint "vodítka viz .claude/skills/setup-from-template/SKILL.md — Krok 2"
}

# --- Subcommand: check ---

cmd_check() {
  local quick=0
  local only_template=0
  local fix=0
  local person=""
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_check_usage
        return 0
        ;;
      --quick) quick=1 ;;
      --template-placeholders) only_template=1 ;;
      --fix) fix=1 ;;
      --person=*) person="${arg#--person=}" ;;
      *)
        fail "doctor check nezná argument: $arg"
        hint "spusť 'doctor check --help'"
        return 2
        ;;
    esac
  done

  if [[ "$only_template" -eq 1 ]]; then
    _check_template_placeholders
    _check_summary
    return 0
  fi

  if [[ -z "$person" ]]; then
    person="$(infer_person_from_pwd)"
  fi

  if [[ "$fix" -eq 1 ]]; then
    local repair_args=()
    [[ "$quick" -eq 1 ]] && repair_args+=(--quick)
    [[ -n "$person" ]] && repair_args+=("--person=${person}")
    if [[ "${#repair_args[@]}" -gt 0 ]]; then
      cmd_repair_local "${repair_args[@]}"
    else
      cmd_repair_local
    fi
    return $?
  fi

  header "Git setup"
  if [[ -d "${ROOT_DIR}/.git" || -f "${ROOT_DIR}/.git" ]]; then
    ok "${ROOT_DIR} je git repo"
  else
    fail "${ROOT_DIR} není git repo"
  fi

  local super_branch
  super_branch="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || echo "")"
  if [[ -z "$super_branch" ]]; then
    fail "super-repo je v detached HEAD"
    hint "spusť 'git checkout main'"
  elif [[ "$super_branch" == "main" ]]; then
    ok "super-repo na branchi main"
  else
    warn "super-repo na branchi '${super_branch}' (očekáváno: main)"
  fi

  if git -C "$ROOT_DIR" remote get-url origin >/dev/null 2>&1; then
    ok "origin remote nastaven: $(git -C "$ROOT_DIR" remote get-url origin)"
  else
    warn "origin remote neni nastaven"
    hint "ocekavano: git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git"
  fi

  header "Claude Code entrypoint"
  local claude_entrypoint="${ROOT_DIR}/CLAUDE.md"
  if [[ -f "$claude_entrypoint" ]]; then
    ok "CLAUDE.md existuje"
    if grep -q 'AGENTS.md' "$claude_entrypoint" && grep -q 'check-my-context' "$claude_entrypoint"; then
      ok "CLAUDE.md odkazuje na AGENTS.md a preflight"
    else
      fail "CLAUDE.md neobsahuje odkaz na AGENTS.md nebo check-my-context"
      hint "drž CLAUDE.md jako tenký Claude Code bootstrap na root AGENTS.md"
    fi
  else
    fail "CLAUDE.md chybí; Claude Code nemá nativní GEN2 bootstrap"
    hint "vytvoř CLAUDE.md jako krátký odkaz na AGENTS.md a doctor check-my-context"
  fi

  header "Skills entrypointy"
  local claude_skills="${ROOT_DIR}/.claude/skills"
  local codex_skills="${ROOT_DIR}/.agents/skills"
  if [[ -d "$claude_skills" ]]; then
    ok ".claude/skills existuje (source of truth)"
  else
    fail ".claude/skills chybí"
  fi
  if [[ -L "$codex_skills" ]]; then
    local target
    target="$(readlink "$codex_skills")"
    if [[ "$target" == "../.claude/skills" ]]; then
      ok ".agents/skills je symlink na .claude/skills"
    else
      warn ".agents/skills je symlink, ale míří na ${target}"
      hint "očekáváno: ln -s ../.claude/skills .agents/skills"
    fi
  elif [[ -e "$codex_skills" ]]; then
    fail ".agents/skills není symlink; hrozí drift mezi Claude a Codex skills"
    hint "nahraď ho symlinkem: ln -s ../.claude/skills .agents/skills"
  else
    fail ".agents/skills chybí; Codex neuvidí workspace skills"
    hint "vytvoř symlink: mkdir -p .agents && ln -s ../.claude/skills .agents/skills"
  fi
  local skill_count
  skill_count="$(find -L "$claude_skills" -mindepth 2 -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "${skill_count:-0}" -gt 0 ]]; then
    ok "${skill_count} sdílených skillů v Git knihovně"
  else
    warn "nenalezen žádný SKILL.md v .claude/skills"
  fi

  header "Coworker-machine tooling"
  if is_macos; then
    if command -v brew >/dev/null 2>&1; then
      ok "brew dostupný ($(brew --version 2>&1 | head -n 1))"
    else
      warn "brew není v PATH"
      hint_classified "user-action" "local-only" "nainstaluj Homebrew; Workspace standardně používá brew pro git, gh, bun a codex"
    fi
  else
    printf '  [info] Homebrew check se vztahuje primárně na macOS kolegy
'
  fi
  for tool in git gh bun codex; do
    check_required_tool "$tool"
  done

  local super_ab super_ahead super_behind
  super_ab="$(module_ahead_behind ".")"
  super_ahead="$(awk '{print $1}' <<<"$super_ab")"
  super_behind="$(awk '{print $2}' <<<"$super_ab")"
  if [[ "$super_behind" != "-" && "$super_behind" -gt 0 ]]; then
    warn "super-repo je ${super_behind} commitů pozadu vůči origin/${super_branch:-main}"
    hint_classified "agent-safe" "git-sync" "spusť 'doctor sync' až nebude root dirty; doctor root pull při dirty rootu neudělá"
  fi
  if [[ "$super_ahead" != "-" && "$super_ahead" -gt 0 ]]; then
    warn "super-repo má ${super_ahead} lokálních commitů čekajících na push"
  fi

  header "Nested repo manifest"
  if [[ -f "${ROOT_DIR}/.gitmodules" ]]; then
    fail ".gitmodules existuje; AgentMint používá manifest-only nested repo model"
    hint_classified "agent-safe" "git-sync" "odstraň .gitmodules a netrackuj modules/* jako gitlink pointery"
  else
    ok ".gitmodules neexistuje"
  fi
  local gitlink_lines
  gitlink_lines="$(git -C "$ROOT_DIR" ls-files -s | awk '$1 == "160000" { print }')"
  if [[ -n "$gitlink_lines" ]]; then
    fail "super-repo trackuje 160000 gitlink pointer"
    while IFS= read -r line; do
      [[ -n "$line" ]] && hint "$line"
    done <<<"$gitlink_lines"
    hint_classified "agent-safe" "git-sync" "odstraň gitlink z indexu; nested repa z manifestu mají být ignorovaná super-repem"
  else
    ok "super-repo netrackuje nested repo gitlink pointery"
  fi

  local active_count=0 planned_count=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ -n "$(manifest_module_url "$path")" ]]; then
      active_count=$((active_count+1))
    else
      planned_count=$((planned_count+1))
    fi
  done < <(manifest_submodule_paths)
  ok "aktivní nested repo sloty: ${active_count}"
  if [[ "$planned_count" -gt 0 ]]; then
    warn "planned slots bez git.url: ${planned_count}"
  fi

  # branch = main konvence
  local missing_branch=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local branch_val
    branch_val="$(manifest_module_branch "$path")"
    if [[ "$branch_val" != "main" ]]; then
      missing_branch=$((missing_branch+1))
      warn "${path}: manifest git.branch není main (hodnota: '${branch_val}')"
    fi
  done < <(gitmodule_paths)
  if [[ "$missing_branch" -eq 0 ]]; then
    ok "všechny aktivní nested repo moduly mají branch main"
  fi

  header "Repo branch health"
  local branch_issues=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local state branch expected
    state="$(module_state "$path")"
    [[ "$state" == "available" ]] || continue

    branch="$(submodule_branch "$path")"
    expected="$(submodule_expected_branch "$path")"

    if [[ "$branch" == "detached" ]]; then
      branch_issues=$((branch_issues+1))
      fail "${path}: detached HEAD (očekáváno: ${expected})"
      hint_classified "agent-safe" "local-only" "doctor check --fix přepne clean detached nested repo modul zpět na ${expected}, pokud HEAD odpovídá tipu větve"
      continue
    fi

    if [[ "$branch" != "$expected" ]]; then
      if repo_allows_non_main_branch "$path" "$branch"; then
        local branch_reason
        branch_reason="$(repo_non_main_branch_reason "$path" "$branch")"
        ok "${path}: větev '${branch}' je povolená (${branch_reason}; manifest baseline: ${expected})"
      else
        branch_issues=$((branch_issues+1))
        warn "${path}: větev '${branch}' (očekáváno: ${expected})"
        hint "ověř, jestli je jiná větev záměrná; jinak přepni na ${expected}"
      fi
    fi
  done < <(gitmodule_paths)
  if [[ "$branch_issues" -eq 0 ]]; then
    ok "všechny dostupné nested repo moduly jsou na očekávané větvi nebo povoleném workflow"
  fi

  header "Fork nested repo moduly"
  # Iterujeme přes moduly v manifestu s fork_upstream polem.
  # Každý fork musí mít: origin, upstream, <parent>-origin remoty a
  # rerere.enabled=true. Viz ARCHITECTURE §19.
  local fork_count=0
  while IFS= read -r fork_path; do
    [[ -z "$fork_path" ]] && continue
    fork_count=$((fork_count+1))

    if [[ ! -d "${ROOT_DIR}/${fork_path}" ]] || \
       { [[ ! -d "${ROOT_DIR}/${fork_path}/.git" ]] && [[ ! -f "${ROOT_DIR}/${fork_path}/.git" ]]; }; then
      printf '  [skip] %s neexistuje lokálně (není init)\n' "$fork_path"
      continue
    fi

    local mirror source parent_name
    mirror="$(jq -r --arg p "$fork_path" \
      '.module_slots[] | select(.path==$p) | .fork_upstream.mirror' \
      "$MANIFEST")"
    source="$(jq -r --arg p "$fork_path" \
      '.module_slots[] | select(.path==$p) | .fork_upstream.source' \
      "$MANIFEST")"
    parent_name="$(basename -s .git "$mirror")"

    # upstream remote
    local upstream_url
    upstream_url="$(git -C "${ROOT_DIR}/${fork_path}" remote get-url upstream 2>/dev/null || echo "")"
    if [[ "$upstream_url" == "$mirror" ]]; then
      ok "${fork_path}: upstream → ${mirror}"
    else
      warn "${fork_path}: upstream remote != ${mirror} (aktuální: ${upstream_url:-<chybí>})"
      hint "git -C ${fork_path} remote add upstream ${mirror}"
    fi

    # <parent>-origin remote
    local parent_url
    parent_url="$(git -C "${ROOT_DIR}/${fork_path}" remote get-url "${parent_name}-origin" 2>/dev/null || echo "")"
    if [[ "$parent_url" == "$source" ]]; then
      ok "${fork_path}: ${parent_name}-origin → ${source}"
    else
      warn "${fork_path}: ${parent_name}-origin != ${source} (aktuální: ${parent_url:-<chybí>})"
      hint "git -C ${fork_path} remote add ${parent_name}-origin ${source}"
    fi

    # rerere
    local rerere
    rerere="$(git -C "${ROOT_DIR}/${fork_path}" config --get rerere.enabled 2>/dev/null || echo "false")"
    if [[ "$rerere" == "true" ]]; then
      ok "${fork_path}: rerere.enabled=true"
    else
      warn "${fork_path}: rerere.enabled není true — kritické pro fork rebase workflow"
      hint "git -C ${fork_path} config rerere.enabled true"
    fi
  done < <(jq -r '.module_slots[] | select(.fork_upstream != null) | .path' "$MANIFEST")

  if [[ "$fork_count" -eq 0 ]]; then
    printf '  [info] žádný fork modul v manifestu\n'
  fi

  if [[ "$quick" -eq 1 ]]; then
    header "Quick mode — přeskakuji SSH/MCP/dependency checks"
    _check_summary
    return 0
  fi

  header "SSH přístup"
  if git -C "$ROOT_DIR" remote get-url origin >/dev/null 2>&1; then
    local ssh_output
    ssh_output="$(ssh -T -o StrictHostKeyChecking=accept-new -o BatchMode=yes git@github.com 2>&1 || true)"
    if echo "$ssh_output" | grep -q "successfully authenticated"; then
      ok "SSH na github.com funguje"
    else
      warn "SSH na github.com neodpověděl očekávanou hláškou"
      hint "ověř 'ssh -T git@github.com' ručně"
      hint "výstup byl: ${ssh_output}"
    fi
  else
    warn "SSH remote check přeskočen — workspace nemá origin remote"
    hint "očekáváno: git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git"
  fi

  header "OS tooling"
  for tool in jq node; do
    if command -v "$tool" >/dev/null 2>&1; then
      ok "$tool dostupný ($($tool --version 2>&1 | head -n 1))"
    else
      warn "$tool není v PATH"
      hint_classified "user-action" "local-only" "viz fixes/tooling-missing.md"
    fi
  done

  check_workspace_tasks

  header "Launchpad runtime"
  if [[ -d "${ROOT_DIR}/launchpad/app/v1" ]]; then
    ok "launchpad/app/v1/ existuje (in-tree GEN2)"
  else
    warn "launchpad/app/v1/ neexistuje"
  fi

  check_launchpad_app_install
  check_firebase_env_bootstrap
  check_person_overlay_bootstrap "$person"

  header "Node závislosti aplikací"
  local dep_total=0 dep_missing=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    dep_total=$((dep_total+1))
    local health
    health="$(dep_dir_health "$app_dir")"
    if [[ "$health" != "ok" ]]; then
      dep_missing=$((dep_missing+1))
      warn "${app_dir} — $(dep_dir_health_message "$app_dir" "$health")"
    fi
  done < <(list_node_project_dirs)
  if [[ "$dep_total" -eq 0 ]]; then
    printf '  [info] žádný Node projekt s package.json\n'
  elif [[ "$dep_missing" -eq 0 ]]; then
    ok "všech ${dep_total} Node projektů má platné závislosti"
  else
    hint_classified "agent-safe" "local-only" "spusť 'doctor check --fix' pro frozen lokální opravu, nebo 'doctor install-deps' pro plný dependency repair"
  fi

  header "MCP konfigurace (per-person)"
  local person_settings="${ROOT_DIR}/company/colleagues/*/.claude/settings.json"
  local user_settings="${HOME}/.claude/settings.json"
  local user_mcp_state="${HOME}/.claude.json"
  if [[ -f "$user_mcp_state" ]]; then
    ok "~/.claude.json existuje (Claude Code user MCP config)"
  elif [[ -f "$user_settings" ]]; then
    ok "~/.claude/settings.json existuje"
  else
    warn "~/.claude.json ani ~/.claude/settings.json neexistují"
  fi
  hint_classified "user-action" "external-write" "MCP secrets MUSÍ zůstat mimo Git. Viz root AGENTS.md §5."

  _check_summary
}

cmd_repair_local() {
  local quick=0
  local person=""
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_repair_local_usage
        return 0
        ;;
      --quick) quick=1 ;;
      --person=*) person="${arg#--person=}" ;;
      *)
        fail "doctor repair-local nezná argument: $arg"
        hint "spusť 'doctor repair-local --help'"
        return 2
        ;;
    esac
  done

  if [[ -z "$person" ]]; then
    person="$(infer_person_from_pwd)"
  fi

  header "Local repair boundary"
  ok "repair-local nedělá commit, push, rebase, root pull ani externí write akce"
  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]]; then
    warn "super-repo je dirty — repair-local root pull nespustí"
    if root_dirty_only_submodule_pointers; then
      hint_classified "needs-approval" "git-sync" "root obsahuje legacy submodule pointer změny; nejdřív je odstraň z indexu"
    else
      hint_classified "user-action" "git-sync" "nejdřív review/stash/commit lokální root změny, potom může doctor sync stáhnout root"
    fi
  fi

  repair_missing_env_locals
  repair_node_deps_local
  repair_detached_submodules_local
  repair_coworker_tooling_local

  header "Post-repair doctor check"
  local check_args=()
  [[ "$quick" -eq 1 ]] && check_args+=(--quick)
  [[ -n "$person" ]] && check_args+=("--person=${person}")
  if [[ "${#check_args[@]}" -gt 0 ]]; then
    (cmd_check "${check_args[@]}")
  else
    (cmd_check)
  fi
  return $?
}

_summary() {
  local label="${1:-Check}"
  printf '\n'
  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    printf '%s%s complete: %d fail, %d warn.%s\n' "$C_FAIL" "$label" "$FAIL_COUNT" "$WARN_COUNT" "$C_RST"
    exit 2
  elif [[ "$WARN_COUNT" -gt 0 ]]; then
    printf '%s%s complete: %d warn.%s Doctor doporučuje projít hints.\n' "$C_WARN" "$label" "$WARN_COUNT" "$C_RST"
    exit 1
  else
    printf '%s%s complete: vše v pořádku.%s\n' "$C_OK" "$label" "$C_RST"
  fi
}

_check_summary() { _summary "Check"; }
_sync_summary()  { _summary "Sync"; }
_push_summary()  { _summary "Push"; }

# --- Subcommand: check-my-context ---

cmd_check_my_context() {
  if has_help_arg "$@"; then
    print_check_my_context_usage
    return 0
  fi
  if [[ "$#" -gt 0 ]]; then
    fail "doctor check-my-context nezná argument: $1"
    hint "spusť 'doctor check-my-context --help'"
    return 2
  fi

  local pwd_abs role_guess
  pwd_abs="$(pwd -P)"

  header "Kontextový scope"
  printf '  pwd: %s\n' "$pwd_abs"

  # Root AGENTS.md
  local agents_root="${ROOT_DIR}/AGENTS.md"
  [[ -f "$agents_root" ]] && ok "root AGENTS.md: ${agents_root}" || warn "root AGENTS.md chybí"

  # Person overlay podle pwd
  if [[ "$pwd_abs" == "${ROOT_DIR}/company/colleagues/"* ]]; then
    local person_dir="${ROOT_DIR}/company/colleagues/$(echo "$pwd_abs" | sed -E "s|${ROOT_DIR}/company/colleagues/([^/]+).*|\1|")"
    [[ -f "${person_dir}/AGENTS.md" ]] && ok "person overlay: ${person_dir}/AGENTS.md" \
      || warn "person overlay ${person_dir}/AGENTS.md chybí"
  fi

  # Module AGENTS
  if [[ "$pwd_abs" == "${ROOT_DIR}/modules/"* ]]; then
    local module_root="${ROOT_DIR}/modules/$(echo "$pwd_abs" | sed -E "s|${ROOT_DIR}/modules/([^/]+).*|\1|")"
    [[ -f "${module_root}/AGENTS.md" ]] && ok "module AGENTS: ${module_root}/AGENTS.md" \
      || printf '  [info] module AGENTS: %s/AGENTS.md neexistuje (OK, ne všechny moduly ho mají)\n' "$module_root"
  fi

  header "Role"
  printf '  Rozhodnutí o aktivní roli dělá uživatel nebo osobní AGENTS.md.\n'
  printf '  Role definice: ls %s/company/roles/\n' "$ROOT_DIR"

  header "Skills"
  printf '  Sdílené source of truth: %s/.claude/skills/\n' "$ROOT_DIR"
  printf '  Claude Code entrypoint:  %s/CLAUDE.md -> AGENTS.md\n' "$ROOT_DIR"
  printf '  Codex entrypoint:        %s/.agents/skills -> ../.claude/skills\n' "$ROOT_DIR"
  printf '  Osobní Git-tracked:      %s/company/colleagues/<ty>/.claude/skills/\n' "$ROOT_DIR"

  printf '\n  Detail kaskády: root AGENTS.md §1 a §12.\n'
}

# --- Subcommand: workspace-tasks ---

check_workspace_tasks() {
  header "Workspace task files"
  if ! command -v node >/dev/null 2>&1; then
    warn "node není v PATH, přeskakuji workspace task validaci"
    hint_classified "user-action" "local-only" "nainstaluj Node a spusť 'doctor workspace-tasks'"
    return 0
  fi

  if (
    cd "$ROOT_DIR"
    node company/scripts/check-workspace-tasks.mjs
  ); then
    ok "Git-native task soubory jsou validní"
  else
    fail "Git-native task soubory nejsou validní"
    hint "spusť 'doctor workspace-tasks' a oprav uvedené TODO/DONE/ISSUES JSON soubory"
  fi
}

cmd_workspace_tasks() {
  if has_help_arg "$@"; then
    print_workspace_tasks_usage
    return 0
  fi
  if [[ "$#" -gt 0 ]]; then
    fail "doctor workspace-tasks nezná argument: $1"
    hint "spusť 'doctor workspace-tasks --help'"
    return 2
  fi

  require_cmd node
  (
    cd "$ROOT_DIR"
    node company/scripts/check-workspace-tasks.mjs
  )
}

# --- Subcommand: sync ---

cmd_sync() {
  local rebase=0
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_sync_usage
        return 0
        ;;
      --rebase) rebase=1 ;;
      *)
        fail "doctor sync nezná argument: $arg"
        hint "spusť 'doctor sync --help'"
        return 2
        ;;
    esac
  done

  local sync_before
  sync_before="$(mktemp "${TMPDIR:-/tmp}/doctor-sync-before.XXXXXX")"
  sync_pointer_snapshot "$sync_before"

  header "Super-repo pull"
  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]]; then
    warn "super-repo je dirty — přeskakuji pull"
    hint_classified "user-action" "git-sync" "commit/stash lokální změny a spusť doctor sync znovu; root pull čeká na clean worktree"
  else
    if [[ "$rebase" -eq 1 ]]; then
      if git -C "$ROOT_DIR" pull --rebase origin main; then
        ok "super-repo pull --rebase"
      else
        fail "super-repo pull --rebase selhal"
        hint "viz fixes/super-repo-pull-rebase-failed.md"
        return 2
      fi
    else
      if git -C "$ROOT_DIR" pull --ff-only origin main; then
        ok "super-repo pull --ff-only"
      else
        fail "super-repo pull --ff-only selhal (možná diverged)"
        hint "spusť 'doctor sync --rebase' nebo viz fixes/super-repo-diverged.md"
        return 2
      fi
    fi
  fi

  header "Nested repo sync"
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue

    local state
    state="$(module_state "$path")"

    if [[ "$state" == "planned_slot" ]]; then
      printf '  [skip] %s (state: %s)\n' "$path" "$state"
      continue
    fi

    local branch expected
    branch="$(submodule_branch "$path")"
    expected="$(submodule_expected_branch "$path")"
    if [[ "$branch" == "detached" && "$state" == "available" ]]; then
      if ! ensure_submodule_expected_branch "$path"; then
        warn "$path: detached HEAD a checkout ${expected} selhal — skip sync"
        hint_classified "needs-approval" "git-sync" "zkontroluj ${path} ručně; doctor sync nebude měnit dirty nebo nejasný nested repo modul"
        continue
      fi
    fi

    if [[ "$state" == "available" ]]; then
      local dirty_flag
      dirty_flag="$(submodule_dirty "$path")"
      if [[ "$dirty_flag" == "dirty" ]]; then
        warn "$path — dirty, skip"
        continue
      fi
    fi

    if [[ "$state" == "missing_access" ]]; then
      local url parent
      url="$(manifest_module_url "$path")"
      parent="$(dirname "${ROOT_DIR}/${path}")"
      mkdir -p "$parent"
      if git clone --branch "$expected" --single-branch "$url" "${ROOT_DIR}/${path}" >/dev/null 2>&1; then
        ok "$path naklonován"
      else
        warn "$path missing_access — clone selhal"
        hint_classified "user-action" "git-sync" "ověř GitHub/SSH přístup na ${url}"
      fi
    elif git -C "${ROOT_DIR}/${path}" pull --ff-only origin "${expected}" >/dev/null 2>&1; then
      ok "$path synced"
    else
      warn "$path pull --ff-only selhal"
      hint_classified "user-action" "git-sync" "pravděpodobně lokální commity nebo divergentní historie; vyřeš ručně uvnitř modulu"
    fi
  done < <(gitmodule_paths)

  print_sync_pointer_handoff "$sync_before"
  rm -f "$sync_before"

  _sync_summary
}

# --- Subcommand: init ---

cmd_init() {
  local install_deps=1
  local install_launchpad=1
  local launchpad_skip_dock=0
  local check_mode="quick"
  local disk_check=1

  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_init_usage
        return 0
        ;;
      --skip-deps)
        install_deps=0
        ;;
      --skip-launchpad-install)
        install_launchpad=0
        ;;
      --skip-dock)
        launchpad_skip_dock=1
        ;;
      --check)
        check_mode="full"
        ;;
      --quick-check)
        check_mode="quick"
        ;;
      --no-check)
        check_mode="none"
        ;;
      --skip-disk-check)
        disk_check=0
        ;;
      *)
        fail "doctor init nezná argument: $arg"
        hint "spusť 'doctor init --help'"
        return 2
        ;;
    esac
  done

  header "Workspace init"
  printf '  root: %s\n' "$ROOT_DIR"
  printf '  manifest: %s\n' "$MANIFEST"

  if [[ "$disk_check" -eq 1 ]]; then
    check_init_disk_space 8 || return $?
  else
    printf '  [skip] disk space preflight (--skip-disk-check)\n'
  fi

  repair_coworker_tooling_local || true

  header "Nested repo init"
  local total=0 available=0 missing=0 planned=0 skipped_platform=0 cloned=0 branch_fixed=0 branch_failed=0
  local module
  while IFS= read -r module; do
    [[ -z "$module" ]] && continue
    total=$((total+1))

    if ! manifest_slot_supports_current_platform "$module"; then
      skipped_platform=$((skipped_platform+1))
      printf '[skipped_platform] %s\n' "$module"
      continue
    fi

    if ! is_gitmodule_path "$module"; then
      planned=$((planned+1))
      printf '[planned_slot] %s\n' "$module"
      continue
    fi

    if [[ "$(module_state "$module")" == "available" ]]; then
      printf '[available] %s\n' "$module"
      if ensure_submodule_expected_branch "$module" preserve-head; then
        branch_fixed=$((branch_fixed+1))
      else
        branch_failed=$((branch_failed+1))
      fi
      available=$((available+1))
    elif [[ "$(module_state "$module")" == "missing_access" ]]; then
      local url branch parent
      url="$(manifest_module_url "$module")"
      branch="$(manifest_module_branch "$module")"
      parent="$(dirname "${ROOT_DIR}/${module}")"
      mkdir -p "$parent"
      if git clone --branch "$branch" --single-branch "$url" "${ROOT_DIR}/${module}" >/dev/null 2>&1; then
        cloned=$((cloned+1))
        available=$((available+1))
        printf '[cloned] %s\n' "$module"
      else
        missing=$((missing+1))
        printf '[missing_access_or_not_ready] %s\n' "$module"
      fi
    else
      planned=$((planned+1))
      printf '[planned_slot] %s\n' "$module"
    fi
  done < <(manifest_submodule_paths)

  local nested_count=0 nested_path
  while IFS= read -r nested_path; do
    [[ -z "$nested_path" ]] && continue
    nested_count=$((nested_count+1))
  done < <(manifest_nested_submodule_paths)
  if [[ "$nested_count" -gt 0 ]]; then
    printf '  [info] hlubší nested sloty v manifestu: %d\n' "$nested_count"
  fi

  header "Fork module config"
  configure_manifest_fork_submodules

  printf '\n  Init: %d slotů — %d available, %d cloned, %d missing/access, %d planned, %d skipped platform, %d branch OK/fixed, %d branch failed\n' \
    "$total" "$available" "$cloned" "$missing" "$planned" "$skipped_platform" "$branch_fixed" "$branch_failed"

  if [[ "$install_deps" -eq 1 ]]; then
    header "Dependency install"
    if command -v bun >/dev/null 2>&1; then
      local deps_rc=0
      cmd_install_deps || deps_rc=$?
      if [[ "$deps_rc" -ne 0 ]]; then
        warn "doctor install-deps skončil s rc=${deps_rc}"
      fi
    else
      warn "bun není v PATH — přeskakuji instalaci Node závislostí"
      hint "nainstaluj bun a spusť 'doctor install-deps'"
    fi
  else
    printf '  [skip] dependency install (--skip-deps)\n'
  fi

  if [[ "$install_launchpad" -eq 1 ]]; then
    local launchpad_rc=0
    if [[ "$launchpad_skip_dock" -eq 1 ]]; then
      cmd_install_launchpad --skip-dock || launchpad_rc=$?
    else
      cmd_install_launchpad || launchpad_rc=$?
    fi
    if [[ "$launchpad_rc" -ne 0 ]]; then
      warn "doctor install-launchpad skončil s rc=${launchpad_rc}"
      hint "oprav Launchpad install a spusť 'doctor install-launchpad' znovu"
    fi
  else
    printf '  [skip] Launchpad install (--skip-launchpad-install)\n'
  fi

  case "$check_mode" in
    full)
      header "Final doctor check"
      local check_rc=0
      (cmd_check) || check_rc=$?
      ;;
    quick)
      header "Final doctor check --quick"
      local check_rc=0
      (cmd_check --quick) || check_rc=$?
      ;;
    none)
      local check_rc=0
      printf '  [skip] final doctor check (--no-check)\n'
      ;;
  esac

  if [[ "$missing" -gt 0 ]]; then
    warn "některé nested repo moduly se nepodařilo inicializovat"
    hint "ověř SSH přístup ke GitHubu a spusť 'doctor init' znovu"
  fi

  if [[ "${check_rc:-0}" -ge 2 ]]; then
    fail "final doctor check selhal (rc=${check_rc})"
  elif [[ "${check_rc:-0}" -eq 1 ]]; then
    warn "final doctor check má doporučení (rc=${check_rc})"
  fi

  if [[ "$branch_failed" -gt 0 ]]; then
    fail "některé nested repo moduly se nepodařilo přepnout na očekávanou větev"
  fi

  if [[ "$WARN_COUNT" -gt 0 || "$FAIL_COUNT" -gt 0 ]]; then
    _summary "Init"
  else
    printf '\n%sInit complete: základní inicializace doběhla.%s\n' "$C_OK" "$C_RST"
  fi
}

# --- Subcommand: push ---

normalize_push_path() {
  local path="$1"
  path="${path%/}"
  if [[ -z "$path" || "$path" == "." || "$path" == "/" ]]; then
    return 1
  fi
  case "$path" in
    /*|..|../*|*/..|*/../*)
      return 1
      ;;
  esac
  printf '%s\n' "$path"
}

array_contains() {
  local needle="$1"; shift || true
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

is_gitmodule_path() {
  local needle="$1" path
  while IFS= read -r path; do
    [[ "$path" == "$needle" ]] && return 0
  done < <(gitmodule_paths)
  return 1
}

root_dirty_only_submodule_pointers() {
  return 1
}

sync_pointer_snapshot() {
  local file="$1"
  : >"$file"
  local path
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    [[ "$(module_state "$path")" == "available" ]] || continue
    local head
    head="$(git -C "${ROOT_DIR}/${path}" rev-parse --short=12 HEAD 2>/dev/null || true)"
    [[ -n "$head" ]] && printf '%s\t%s\n' "$path" "$head" >>"$file"
  done < <(gitmodule_paths)
}

print_sync_pointer_handoff() {
  local before_file="$1"

  header "Nested repo sync handoff"
  local changed=0 line path before after dirty
  while IFS=$'\t' read -r path before; do
    [[ -z "$path" ]] && continue
    [[ "$(module_state "$path")" == "available" ]] || continue
    after="$(git -C "${ROOT_DIR}/${path}" rev-parse --short=12 HEAD 2>/dev/null || true)"
    [[ -n "$after" ]] || continue
    if [[ "$before" != "$after" ]]; then
      dirty="$(submodule_dirty "$path")"
      printf '  [nested] %s: %s -> %s (module: %s)\n' "$path" "$before" "$after" "$dirty"
      changed=$((changed+1))
    fi
  done <"$before_file"

  if [[ "$changed" -eq 0 ]]; then
    ok "sync neposunul žádné nested repo HEADy"
  fi

  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]]; then
    warn "super-repo má lokální změny"
    hint_classified "user-action" "git-sync" "nejdřív review 'git status --short'; doctor sync root pull počká na clean/stash/commit"
  fi
}

is_sensitive_root_path() {
  local path="$1"
  case "$path" in
    .claude|.claude/*|company|company/colleagues|company/colleagues/*|infra|infra/access|infra/access/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_sensitive_module_path() {
  local path="$1"
  case "$path" in
    infra)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

module_has_own_push_workflow() {
  local path="$1"
  case "$path" in
    modules/monorepo|modules/firmware)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

root_path_exists_or_tracked() {
  local path="$1"
  [[ -e "${ROOT_DIR}/${path}" ]] && return 0
  git -C "$ROOT_DIR" ls-files --error-unmatch -- "$path" >/dev/null 2>&1
}

firebase_mirror_dirty() {
  [[ -n "$(git -C "${ROOT_DIR}/modules/firebase" status --porcelain -- mirror 2>/dev/null || true)" ]]
}

root_path_dirty() {
  local path="$1"
  [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- "$path" 2>/dev/null || true)" ]]
}

root_path_selected_by_include() {
  local required_path="$1"
  shift || true
  local include_path
  for include_path in "$@"; do
    [[ -z "$include_path" ]] && continue
    if [[ "$required_path" == "$include_path" || "$required_path" == "$include_path"/* || "$include_path" == "$required_path"/* ]]; then
      return 0
    fi
  done
  return 1
}

module_uses_launchpad_contracts() {
  local module_path="$1"
  local module_abs="${ROOT_DIR}/${module_path}"
  [[ -d "$module_abs" ]] || return 1

  if command -v rg >/dev/null 2>&1; then
    (
      cd "$module_abs" &&
      rg -q '(@workspace-contracts/v1|launchpad/contracts)' \
        --glob '!node_modules/**' \
        --glob '!dist/**' \
        --glob '!build/**' \
        --glob '!coverage/**' \
        .
    ) >/dev/null 2>&1
    return $?
  fi

  git -C "$module_abs" grep -q -E '(@workspace-contracts/v1|launchpad/contracts)' -- . >/dev/null 2>&1
}

commit_message_subject() {
  local msg="$1"
  printf '%s\n' "$msg" | sed -n '1p' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

commit_message_body_line_count() {
  local msg="$1"
  printf '%s\n' "$msg" | awk 'NR > 1 && $0 !~ /^[[:space:]]*$/ { count++ } END { print count + 0 }'
}

indent_message() {
  local msg="$1"
  printf '%s\n' "$msg" | sed 's/^/    /'
}

message_with_subject_suffix() {
  local msg="$1"
  local suffix="$2"
  local subject body
  subject="$(commit_message_subject "$msg")"

  if [[ "$msg" == *$'\n'* ]]; then
    body="${msg#*$'\n'}"
    printf '%s%s\n%s' "$subject" "$suffix" "$body"
  else
    printf '%s%s' "$subject" "$suffix"
  fi
}

cmd_push_validate_message() {
  local msg="$1"
  local scope_count="$2"
  local subject lower body_lines
  subject="$(commit_message_subject "$msg")"
  lower="$(printf '%s' "$subject" | tr '[:upper:]' '[:lower:]')"
  body_lines="$(commit_message_body_line_count "$msg")"

  header "Commit message quality"

  if [[ -z "$subject" ]]; then
    fail "commit message subject je prázdný"
    return 2
  fi

  case "$lower" in
    fix|fixes|update|updates|change|changes|cleanup|wip|misc|stuff|todo|temp)
      fail "commit message je příliš obecná: '$subject'"
      hint "použij tvar 'Area: konkrétní změna' a v těle doplň co/proč/dopad"
      return 2
      ;;
  esac

  if [[ "${#subject}" -lt 12 ]]; then
    fail "commit message subject je příliš krátký: '$subject'"
    hint "release notes z něj nepoznají, co se změnilo"
    return 2
  fi

  if [[ "$subject" != *:* ]]; then
    warn "subject nemá oblast před dvojtečkou"
    hint "doporučený tvar: 'Catalog: Remove invalid service package variant'"
  else
    ok "subject má oblast a konkrétní shrnutí"
  fi

  if [[ "$body_lines" -eq 0 ]]; then
    warn "commit message nemá tělo"
    hint "pro release notes doplň 1-3 odstavce: co se změnilo, proč, dopad/testy"
  else
    ok "message body má kontext pro release notes"
  fi

  if [[ "$scope_count" -gt 1 ]]; then
    warn "push obsahuje více scopes najednou"
    hint "pokud nejde o jeden logický release-note item, rozděl to na více doctor push commitů"
    if [[ "$body_lines" -lt 2 ]]; then
      fail "multi-scope push vyžaduje popsané tělo commit message"
      hint "napiš proč scopes patří do jednoho commitu, nebo je pushni zvlášť"
      return 2
    fi
  fi

  return 0
}

cmd_push_validate_firebase_mirror_sync() {
  local ack="$1"
  shift
  local selected_modules=("$@")

  if ! array_contains "modules/firebase" "${selected_modules[@]}"; then
    return 0
  fi

  if ! firebase_mirror_dirty; then
    return 0
  fi

  header "Firebase mirror production sync"

  if [[ "$ack" -eq 1 ]]; then
    ok "modules/firebase/mirror změny mají explicitní produkční sync ack"
    hint "report musí uvést konkrétní Firestore paths a dry-run/write/verification stav"
    return 0
  fi

  fail "modules/firebase/mirror je dirty, ale chybí produkční sync ack"
  hint "použij skill firebase-mirror-production-sync"
  hint "nejdřív zjisti změněné _firestore.path, spusť cílený dry-run/write/ověření po dokumentech"
  hint "pak pusť doctor push s --firebase-production-synced, nebo uživateli explicitně nahlas odklad produkčního propsání"
  return 2
}

cmd_push_validate_root_dependency_includes() {
  local modules=()
  local includes=()
  local mode="modules"
  local arg

  for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
      mode="includes"
      continue
    fi
    if [[ "$mode" == "modules" ]]; then
      modules+=("$arg")
    else
      includes+=("$arg")
    fi
  done

  [[ "${#modules[@]}" -eq 0 ]] && return 0

  local contracts_path="launchpad/contracts"
  root_path_dirty "$contracts_path" || return 0

  local dependent_modules=()
  local module
  for module in "${modules[@]}"; do
    if module_uses_launchpad_contracts "$module"; then
      dependent_modules+=("$module")
    fi
  done

  [[ "${#dependent_modules[@]}" -eq 0 ]] && return 0

  header "Root dependency includes"

  if root_path_selected_by_include "$contracts_path" "${includes[@]}"; then
    ok "launchpad/contracts je dirty a je součástí root include scope"
    return 0
  fi

  fail "vybraný nested repo modul závisí na @workspace-contracts/v1, ale dirty launchpad/contracts není ve scope"
  for module in "${dependent_modules[@]}"; do
    hint "$module používá launchpad/contracts"
  done
  hint "pusť doctor push znovu s '--include launchpad/contracts' nebo širším '--include launchpad'"
  hint "pokud contracts změna není součást této práce, nejdřív ji odlož/stashni nebo rozděl commit"
  return 2
}

cmd_push_confirm() {
  local yes="$1"
  [[ "$yes" -eq 1 ]] && return 0

  if [[ ! -t 0 ]]; then
    fail "nelze se zeptat na potvrzení v non-interactive shellu"
    hint "přidej --yes, až preview odpovídá tomu, co chceš pushnout"
    return 2
  fi

  local answer
  printf '\nPokračovat s commitem a pushem? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES|ano|ANO)
      return 0
      ;;
    *)
      warn "push zrušen uživatelem"
      return 1
      ;;
  esac
}

cmd_push() {
  # macOS default Bash 3.2 treats empty arrays as unbound under set -u.
  # Push uses optional repeated flags heavily, so relax nounset inside this command.
  set +u

  local msg="" dry_run=0 yes=0 all_modules=0 firebase_production_synced=0
  local explicit_modules=()
  local include_paths=()
  local sensitive_include_paths=()

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -h|--help)
        print_push_usage
        return 0
        ;;
      -m|--message)
        shift
        if [[ "$#" -eq 0 || -z "${1:-}" ]]; then
          fail "--message vyžaduje text"
          return 2
        fi
        msg="$1"
        ;;
      --module)
        shift
        if [[ "$#" -eq 0 ]]; then
          fail "--module vyžaduje cestu k nested repo modulu"
          return 2
        fi
        local module_path
        if ! module_path="$(normalize_push_path "$1")"; then
          fail "neplatná module cesta: $1"
          return 2
        fi
        if ! is_gitmodule_path "$module_path"; then
          fail "$module_path není aktivní nested repo z manifestu"
          return 2
        fi
        explicit_modules+=("$module_path")
        ;;
      --all)
        all_modules=1
        ;;
      --include)
        shift
        if [[ "$#" -eq 0 ]]; then
          fail "--include vyžaduje root cestu"
          return 2
        fi
        local include_path
        if ! include_path="$(normalize_push_path "$1")"; then
          fail "neplatná include cesta: $1"
          return 2
        fi
        if is_sensitive_root_path "$include_path"; then
          fail "$include_path je citlivá root cesta"
          hint "použij explicitně --include-sensitive $include_path"
          return 2
        fi
        if ! root_path_exists_or_tracked "$include_path"; then
          fail "$include_path v rootu neexistuje a není tracked"
          return 2
        fi
        include_paths+=("$include_path")
        ;;
      --include-sensitive)
        shift
        if [[ "$#" -eq 0 ]]; then
          fail "--include-sensitive vyžaduje root cestu"
          return 2
        fi
        local sensitive_path
        if ! sensitive_path="$(normalize_push_path "$1")"; then
          fail "neplatná sensitive include cesta: $1"
          return 2
        fi
        if ! root_path_exists_or_tracked "$sensitive_path"; then
          fail "$sensitive_path v rootu neexistuje a není tracked"
          return 2
        fi
        sensitive_include_paths+=("$sensitive_path")
        ;;
      --firebase-production-synced)
        firebase_production_synced=1
        ;;
      --dry-run)
        dry_run=1
        ;;
      -y|--yes)
        yes=1
        ;;
      --)
        shift
        if [[ "$#" -gt 0 && -z "$msg" ]]; then
          msg="$*"
          break
        fi
        ;;
      -*)
        fail "neznámý doctor push flag: $1"
        hint "spusť 'doctor push --help'"
        return 2
        ;;
      *)
        if [[ -n "$msg" ]]; then
          fail "neočekávaný argument: $1"
          hint "commit message dej jednou přes -m nebo jako první argument"
          return 2
        fi
        msg="$1"
        ;;
    esac
    shift
  done

  if [[ -z "$msg" ]]; then
    printf '%sMusíš dodat commit message.%s\n' "$C_FAIL" "$C_RST" >&2
    printf 'Usage: doctor push -m "<message>" [--module <path>] [--include <path>]\n' >&2
    return 2
  fi
  if [[ "$msg" == -* ]]; then
    fail "commit message nesmí vypadat jako flag: $msg"
    hint "použij -m \"...\" nebo spusť 'doctor push --help'"
    return 2
  fi

  header "Preflight"
  printf '  Spouštím rychlý check...\n'
  # Subshell isoluje WARN/FAIL counter změny z preflightu, aby neznečistily
  # finální push summary.
  local preflight_rc=0
  ( cmd_check --quick >/dev/null 2>&1 ) || preflight_rc=$?
  if [[ "$preflight_rc" -ge 2 ]]; then
    fail "preflight check selhal (rc=${preflight_rc}) — oprav problémy"
    hint "spusť 'doctor check' pro detail"
    return 2
  fi
  ok "preflight OK"

  local selected_modules=()
  local skipped_modules=()
  local auto_modules=()

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local state
    state="$(module_state "$path")"
    if [[ "$state" != "available" ]]; then
      skipped_modules+=("$path (state: $state)")
      continue
    fi
    if [[ "$(submodule_dirty "$path")" != "dirty" ]]; then continue; fi
    if module_has_own_push_workflow "$path"; then
      skipped_modules+=("$path (vlastní workflow)")
      continue
    fi
    if [[ "$all_modules" -eq 1 ]] || { [[ "${#explicit_modules[@]}" -gt 0 ]] && array_contains "$path" "${explicit_modules[@]}"; }; then
      selected_modules+=("$path")
      continue
    fi
    if is_sensitive_module_path "$path"; then
      skipped_modules+=("$path (vyžaduje --module $path nebo --all)")
      continue
    fi
    auto_modules+=("$path")
  done < <(gitmodule_paths)

  if [[ "$all_modules" -eq 0 && "${#explicit_modules[@]}" -eq 0 ]]; then
    if [[ "${#include_paths[@]}" -gt 0 || "${#sensitive_include_paths[@]}" -gt 0 ]]; then
      : # root-scoped push: do not auto-add unrelated dirty nested repos
    elif [[ "${#auto_modules[@]}" -gt 1 ]]; then
      fail "dirty je víc nested repo modulů najednou; vyber scope explicitně"
      if [[ "${#auto_modules[@]}" -gt 0 ]]; then
        for path in "${auto_modules[@]}"; do
          hint "doctor push -m \"$msg\" --module $path"
        done
      fi
      return 2
    elif [[ "${#auto_modules[@]}" -eq 1 ]]; then
      selected_modules+=("${auto_modules[0]}")
    fi
  fi

  local module
  if [[ "${#explicit_modules[@]}" -gt 0 ]]; then
    for module in "${explicit_modules[@]}"; do
      if module_has_own_push_workflow "$module"; then
        fail "$module má vlastní task-driven workflow"
        hint "použij monorepo-fix skill nebo firmware vlastní flow"
        return 2
      fi
      if [[ "$(module_state "$module")" != "available" ]]; then
        fail "$module není dostupný pro push (state: $(module_state "$module"))"
        return 2
      fi
      if [[ "$(submodule_dirty "$module")" != "dirty" ]]; then
        warn "$module není dirty; nebude co commitnout"
      elif [[ "${#selected_modules[@]}" -eq 0 ]] || ! array_contains "$module" "${selected_modules[@]}"; then
        selected_modules+=("$module")
      fi
    done
  fi

  header "Push preview"
  printf '  message:\n'
  indent_message "$msg"
  if [[ "${#selected_modules[@]}" -eq 0 ]]; then
    printf '  modules: žádné\n'
  else
    printf '  modules:\n'
    for module in "${selected_modules[@]}"; do
      printf '    - %s\n' "$module"
    done
  fi

  if [[ "${#include_paths[@]}" -eq 0 && "${#sensitive_include_paths[@]}" -eq 0 ]]; then
    printf '  root includes: žádné explicitní root cesty\n'
  else
    printf '  root includes:\n'
    if [[ "${#include_paths[@]}" -gt 0 ]]; then
      for path in "${include_paths[@]}"; do
        printf '    - %s\n' "$path"
      done
    fi
    if [[ "${#sensitive_include_paths[@]}" -gt 0 ]]; then
      for path in "${sensitive_include_paths[@]}"; do
        printf '    - %s (sensitive)\n' "$path"
      done
    fi
  fi

  if [[ "${#skipped_modules[@]}" -gt 0 ]]; then
    printf '  skipped:\n'
    for path in "${skipped_modules[@]}"; do
      printf '    - %s\n' "$path"
    done
  fi

  local scope_count
  scope_count=$((${#selected_modules[@]} + ${#include_paths[@]} + ${#sensitive_include_paths[@]}))
  cmd_push_validate_message "$msg" "$scope_count" || return $?
  cmd_push_validate_firebase_mirror_sync "$firebase_production_synced" "${selected_modules[@]}" || return $?
  cmd_push_validate_root_dependency_includes "${selected_modules[@]}" -- "${include_paths[@]}" "${sensitive_include_paths[@]}" || return $?

  if [[ "$dry_run" -eq 1 ]]; then
    printf '\n  [info] dry-run: žádný commit ani push neproběhl\n'
    return 0
  fi

  if [[ -n "$(git -C "$ROOT_DIR" diff --cached --name-only)" ]]; then
    fail "root už má staged změny; doctor je nechce smíchat s vlastním commitem"
    hint "commitni/unstagni staged změny a spusť doctor push znovu"
    return 2
  fi

  cmd_push_confirm "$yes" || return $?

  header "Commit+push nested repo modulů"
  local any_committed=0
  local committed_modules=()
  if [[ "${#selected_modules[@]}" -gt 0 ]]; then
    for path in "${selected_modules[@]}"; do
      if [[ "$(submodule_dirty "$path")" != "dirty" ]]; then
        printf '  [skip] %s (clean)\n' "$path"
        continue
      fi

      printf '  → %s\n' "$path"
      local module_commit_msg
      module_commit_msg="$(message_with_subject_suffix "$msg" " (${path})")"
      if ! (cd "${ROOT_DIR}/${path}" && git add -A && git commit -m "$module_commit_msg" >/dev/null); then
        fail "commit v $path selhal"
        return 2
      fi
      if ! (cd "${ROOT_DIR}/${path}" && git push origin main >/dev/null 2>&1); then
        warn "$path: push selhal, zkouším pull --rebase"
        if (cd "${ROOT_DIR}/${path}" && git pull --rebase origin main && git push origin main) >/dev/null 2>&1; then
          ok "$path: pull --rebase + retry push úspěšný"
        else
          fail "$path: push stále selhává, manuální intervence"
          return 2
        fi
      fi
      any_committed=1
      committed_modules+=("$path")
      ok "$path committed a pushnuto"
    done
  fi

  if [[ "$any_committed" -eq 0 ]]; then
    printf '  [info] žádný dirty nested repo modul — přeskakuji module commit\n'
  fi

  if [[ "$any_committed" -eq 1 ]]; then
    header "Super-repo commit"
    local commit_msg="${msg}"
  else
    header "Super-repo commit"
    local commit_msg="${msg}"
  fi

  local root_stage_paths=()
  if [[ "${#include_paths[@]}" -gt 0 ]]; then
    for path in "${include_paths[@]}"; do
      root_stage_paths+=("$path")
    done
  fi
  if [[ "${#sensitive_include_paths[@]}" -gt 0 ]]; then
    for path in "${sensitive_include_paths[@]}"; do
      root_stage_paths+=("$path")
    done
  fi

  if [[ "${#root_stage_paths[@]}" -gt 0 ]]; then
    if ! git -C "$ROOT_DIR" add -- "${root_stage_paths[@]}" >/dev/null; then
      fail "git add root cest selhal"
      return 2
    fi
  fi

  if ! git -C "$ROOT_DIR" diff --cached --quiet --exit-code; then
    if ! git -C "$ROOT_DIR" commit -m "${commit_msg}" >/dev/null; then
      fail "commit super-repa selhal"; return 2
    fi
    ok "super-repo commit"

    if git -C "$ROOT_DIR" push origin main >/dev/null 2>&1; then
      ok "super-repo push"
    else
      warn "super-repo push selhal (možná pointer conflict) — zkus skill 'resolve-pointer-conflict'"
      hint "nebo spusť 'git pull --rebase origin main && git push' ručně"
      return 1
    fi
  else
    printf '  [info] super-repo nemá staged změny — žádný commit\n'
  fi

  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]]; then
    warn "v rootu zůstávají nestagenuté nebo nespárované změny"
    hint "spusť 'git status --short' a případně další scoped 'doctor push'"
  fi

  _push_summary
}

# --- Subcommand: pullable ---
#
# Fetchne origin každého dostupného nested repo modulu (+ super-repa) a
# reportuje, kolik commitů je pozadu. S `--pull` rovnou udělá
# fast-forward pull, kde je to možné. S `--no-fetch` použije
# cached refs (rychlé, ale může být zastaralé).
#
# `--json` výstup spotřebovává Launchpad UI a má tvar:
#   {"repos": [{"path":"modules/X", "ahead":0, "behind":3, ...}]}

cmd_pullable() {
  local json_mode=0 do_pull=0 skip_fetch=0 only_pullable=0
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_pullable_usage
        return 0
        ;;
      --json)       json_mode=1 ;;
      --pull)       do_pull=1 ;;
      --no-fetch)   skip_fetch=1 ;;
      --pullable-only) only_pullable=1 ;;
      *)
        fail "doctor pullable nezná argument: $arg"
        hint "spusť 'doctor pullable --help'"
        return 2
        ;;
    esac
  done

  # Collect paths: super-repo + every available top-level nested repo module.
  local -a paths
  paths=("." )
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    local state
    state="$(module_state "$p")"
    [[ "$state" == "available" ]] || continue
    paths+=("$p")
  done < <(gitmodule_paths)

  # Fetch all in parallel (bounded) unless --no-fetch.
  if [[ "$skip_fetch" -eq 0 ]]; then
    if [[ "$json_mode" -eq 0 ]]; then
      header "Fetch"
      printf '  Stahuji origin refs z %d repozitářů…\n' "${#paths[@]}"
    fi
    local pids=() pid
    for p in "${paths[@]}"; do
      local repo_dir
      repo_dir="${ROOT_DIR}"
      [[ "$p" != "." ]] && repo_dir="${ROOT_DIR}/${p}"
      (git -C "$repo_dir" fetch --quiet origin 2>/dev/null || true) &
      pids+=($!)
      # Omezený parallelism — max 8 paralelních fetchů ať nezahltíme
      if [[ "${#pids[@]}" -ge 8 ]]; then
        for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done
        pids=()
      fi
    done
    for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done
  fi

  # Collect + report.
  local -a results_path results_ahead results_behind results_branch
  local total=0 ahead_total=0 behind_total=0 diverged=0 pullable=0
  for p in "${paths[@]}"; do
    local branch ab ahead behind
    if [[ "$p" == "." ]]; then
      branch="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || echo "")"
      local ref="origin/${branch:-main}"
      local counts
      counts="$(git -C "$ROOT_DIR" rev-list --left-right --count "${ref}...HEAD" 2>/dev/null || echo "")"
      if [[ -z "$counts" ]]; then ab="- -"; else
        behind="$(awk '{print $1}' <<<"$counts")"
        ahead="$(awk '{print $2}' <<<"$counts")"
        ab="${ahead:-0}	${behind:-0}"
      fi
    else
      branch="$(submodule_branch "$p")"
      ab="$(module_ahead_behind "$p")"
    fi

    ahead="$(awk '{print $1}' <<<"$ab")"
    behind="$(awk '{print $2}' <<<"$ab")"

    if [[ "$ahead" == "-" || "$behind" == "-" ]]; then
      [[ "$only_pullable" -eq 1 ]] && continue
      ahead=0; behind=0
    fi

    if [[ "$only_pullable" -eq 1 && "$behind" -eq 0 ]]; then
      continue
    fi

    total=$((total+1))
    ahead_total=$((ahead_total + ahead))
    behind_total=$((behind_total + behind))

    results_path+=("$p")
    results_ahead+=("$ahead")
    results_behind+=("$behind")
    results_branch+=("$branch")

    if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
      diverged=$((diverged+1))
    elif [[ "$behind" -gt 0 ]]; then
      pullable=$((pullable+1))
    fi
  done

  if [[ "$json_mode" -eq 1 ]]; then
    # Manuální JSON sestavení (doctor se snaží minimalizovat jq/python dependencies).
    local first=1
    printf '{"repos":['
    local i=0
    while [[ "$i" -lt "${#results_path[@]}" ]]; do
      if [[ "$first" -eq 1 ]]; then first=0; else printf ','; fi
      printf '{"path":"%s","branch":"%s","ahead":%s,"behind":%s}' \
        "${results_path[$i]}" "${results_branch[$i]:-}" \
        "${results_ahead[$i]}" "${results_behind[$i]}"
      i=$((i+1))
    done
    printf '],"totals":{"total":%d,"ahead":%d,"behind":%d,"pullable":%d,"diverged":%d}}\n' \
      "$total" "$ahead_total" "$behind_total" "$pullable" "$diverged"
    return 0
  fi

  header "Stav"
  local i=0
  while [[ "$i" -lt "${#results_path[@]}" ]]; do
    local p="${results_path[$i]}" a="${results_ahead[$i]}" b="${results_behind[$i]}" br="${results_branch[$i]:-?}"
    if [[ "$a" -gt 0 && "$b" -gt 0 ]]; then
      warn "${p}  (↑${a} ↓${b}, větev ${br}) — rozchází se, potřebuje merge/rebase"
    elif [[ "$b" -gt 0 ]]; then
      warn "${p}  (↓${b} commit$([[ "$b" -gt 1 ]] && echo "ů"), větev ${br}) — je nová verze"
    elif [[ "$a" -gt 0 ]]; then
      printf '  [info] %s  (↑%d commit%s) — čeká push\n' "$p" "$a" "$([[ "$a" -gt 1 ]] && echo "y")"
    else
      ok "${p}  (aktuální)"
    fi
    i=$((i+1))
  done

  printf '\n  Celkem: %d — %d s novými commity, %d rozchází se, %d aktuálních\n' \
    "$total" "$pullable" "$diverged" "$((total - pullable - diverged))"

  # --pull: fast-forward ty, co jsou jen behind (nikoli diverged).
  if [[ "$do_pull" -eq 1 && "$pullable" -gt 0 ]]; then
    header "Pull"
    local pulled=0 failed=0
    i=0
    while [[ "$i" -lt "${#results_path[@]}" ]]; do
      local p="${results_path[$i]}" a="${results_ahead[$i]}" b="${results_behind[$i]}"
      if [[ "$b" -gt 0 && "$a" -eq 0 ]]; then
        local repo_dir="$ROOT_DIR"
        [[ "$p" != "." ]] && repo_dir="${ROOT_DIR}/${p}"
        if git -C "$repo_dir" pull --ff-only --quiet origin 2>/dev/null; then
          ok "${p} pull --ff-only"
          pulled=$((pulled+1))
        else
          fail "${p} pull selhal (možná dirty working tree)"
          failed=$((failed+1))
        fi
      fi
      i=$((i+1))
    done
    printf '\n  Pull: %d úspěšných, %d selhalo\n' "$pulled" "$failed"
  fi

  [[ "$pullable" -gt 0 || "$diverged" -gt 0 ]] && return 1
  return 0
}

# --- Subcommand: port ---
#
# "Co drží port N?" — identifikuje proces, který poslouchá na
# daném portu. Používá lsof (macOS / Linux). Na Windows volá
# netstat -ano.

cmd_port() {
  local target=""
  local json_mode=0
  local do_kill=0
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_port_usage
        return 0
        ;;
      --json)  json_mode=1 ;;
      --kill)  do_kill=1 ;;
      -*)
        fail "doctor port nezná argument: $arg"
        hint "spusť 'doctor port --help'"
        return 2
        ;;
      *)
        if [[ -z "$target" && "$arg" =~ ^[0-9]{1,5}$ ]]; then
          local port_num=$((10#$arg))
          if [[ "$port_num" -ge 1 && "$port_num" -le 65535 ]]; then
            target="$port_num"
          else
            fail "doctor port očekává port v rozsahu 1-65535; dostal: $arg"
            hint "spusť 'doctor port --help'"
            return 2
          fi
        else
          fail "doctor port očekává právě jedno číslo portu; dostal: $arg"
          hint "spusť 'doctor port --help'"
          return 2
        fi
        ;;
    esac
  done

  if [[ -z "$target" ]]; then
    printf 'Usage: doctor port <číslo_portu> [--kill] [--json]\n' >&2
    return 2
  fi

  # Zkusí lsof nejdřív, fallback na ss/netstat.
  local holders=""
  if command -v lsof >/dev/null 2>&1; then
    # -iTCP:PORT jen TCP, -sTCP:LISTEN jen listen sokety, -n bez DNS reverse,
    # -F umožňuje strojové parsování: řádky typu "pPID", "cCMD", "LUSER".
    holders="$(lsof -nP -iTCP:"${target}" -sTCP:LISTEN -F pcL 2>/dev/null || true)"
  fi

  if [[ -z "$holders" ]] && command -v ss >/dev/null 2>&1; then
    # ss fallback pro Linux bez lsof.
    holders="$(ss -tlnpH "( sport = :${target} )" 2>/dev/null | awk -F'users:\\(\\(|\\)\\)' '{print $2}' | head -1)"
  fi

  local found=0
  if [[ "$json_mode" -eq 1 ]]; then
    printf '{"port":%s,"holders":[' "$target"
    local first=1 pid cmd user
    while IFS= read -r line; do
      case "$line" in
        p*) pid="${line#p}" ;;
        c*) cmd="${line#c}" ;;
        L*) user="${line#L}"
            if [[ -n "$pid" ]]; then
              if [[ "$first" -eq 1 ]]; then first=0; else printf ','; fi
              printf '{"pid":%s,"command":"%s","user":"%s"}' "$pid" "${cmd:-}" "${user:-}"
              found=$((found+1))
              pid=""; cmd=""; user=""
            fi ;;
      esac
    done <<< "$holders"
    printf ']}\n'
    [[ "$found" -eq 0 ]] && return 0 || return 1
  fi

  header "Port ${target}"
  local -a pids
  local pid="" cmd="" user=""
  while IFS= read -r line; do
    case "$line" in
      p*) pid="${line#p}" ;;
      c*) cmd="${line#c}" ;;
      L*) user="${line#L}"
          if [[ -n "$pid" ]]; then
            warn "Port ${target} drží: PID ${pid} · ${cmd:-<neznámé>} · user ${user:-<?>}"
            pids+=("$pid")
            found=$((found+1))
            pid=""; cmd=""; user=""
          fi ;;
    esac
  done <<< "$holders"

  if [[ "$found" -eq 0 ]]; then
    ok "Port ${target} není nikým obsazený."
    return 0
  fi

  if [[ "$do_kill" -eq 1 ]]; then
    header "Kill"
    for p in "${pids[@]}"; do
      if kill "$p" 2>/dev/null; then
        ok "kill ${p} odesláno (SIGTERM)"
      else
        fail "kill ${p} selhal — zkus 'kill -9 ${p}' ručně"
      fi
    done
  else
    hint "Zastavit: kill ${pids[*]}   (případně 'kill -9 <PID>' jako poslední záchrana)"
    hint "Spustit s --kill: doctor port ${target} --kill"
  fi

  return 1
}

# --- Subcommand: install-deps ---

cmd_install_deps() {
  local only_missing=1 force=0 target=""
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_install_deps_usage
        return 0
        ;;
      --all) only_missing=0 ;;
      --force) force=1 ;;
      --module=*) target="${arg#--module=}" ;;
      *)
        fail "doctor install-deps nezná argument: $arg"
        hint "spusť 'doctor install-deps --help'"
        return 2
        ;;
    esac
  done

  require_cmd bun

  header "Node závislosti"
  local total=0 installed=0 skipped=0 failed=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    # --module filter (konkrétní nested repo id nebo cesta)
    if ! dep_module_target_matches "$app_dir" "$target"; then
      continue
    fi
    total=$((total+1))

    local health
    health="$(dep_dir_health "$app_dir")"

    if [[ "$only_missing" -eq 1 && "$health" == "ok" && "$force" -eq 0 ]]; then
      printf '  [skip] %s (závislosti vypadají zdravě)\n' "$app_dir"
      skipped=$((skipped+1))
      continue
    fi

    printf '  → %s (%s)\n' "$app_dir" "$(dep_dir_health_message "$app_dir" "$health")"
    if [[ "$health" == "lockfile_out_of_sync" ]]; then
      if (cd "${ROOT_DIR}/${app_dir}" && bun install --silent >/dev/null 2>&1); then
        ok "${app_dir} instalováno"
        installed=$((installed+1))
      else
        fail "${app_dir} — bun install selhal"
        hint "spusť ručně: cd ${app_dir} && bun install"
        failed=$((failed+1))
      fi
      continue
    fi

    if (cd "${ROOT_DIR}/${app_dir}" && bun install --frozen-lockfile --silent >/dev/null 2>&1); then
      ok "${app_dir} instalováno"
      installed=$((installed+1))
    else
      warn "${app_dir} — frozen install selhal, zkouším standard bun install"
      if (cd "${ROOT_DIR}/${app_dir}" && bun install --silent >/dev/null 2>&1); then
        ok "${app_dir} instalováno"
        installed=$((installed+1))
      else
        fail "${app_dir} — bun install selhal"
        hint "spusť ručně: cd ${app_dir} && bun install"
        failed=$((failed+1))
      fi
    fi
  done < <(list_node_project_dirs)

  printf '\n  Celkem: %d projektů — %d nainstalováno, %d přeskočeno, %d selhalo\n' \
    "$total" "$installed" "$skipped" "$failed"

  if [[ "$failed" -gt 0 ]]; then
    return 2
  fi

  header "Dependency re-check"
  local recheck_total=0 recheck_broken=0 retried=0 retry_fixed=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    if ! dep_module_target_matches "$app_dir" "$target"; then
      continue
    fi
    recheck_total=$((recheck_total+1))

    local post_health
    post_health="$(dep_dir_health "$app_dir")"
    if [[ "$post_health" == "ok" ]]; then
      ok "${app_dir}"
      continue
    fi

    warn "${app_dir} pořád není čisté po instalaci — $(dep_dir_health_message "$app_dir" "$post_health")"
    retried=$((retried+1))
    printf '  → cílený reinstall: %s\n' "$app_dir"
    if [[ "$post_health" == "lockfile_out_of_sync" ]]; then
      (cd "${ROOT_DIR}/${app_dir}" && bun install --force --silent >/dev/null 2>&1) || true
    else
      (cd "${ROOT_DIR}/${app_dir}" && bun install --force --frozen-lockfile --silent >/dev/null 2>&1) || true
    fi

    post_health="$(dep_dir_health "$app_dir")"
    if [[ "$post_health" == "ok" ]]; then
      ok "${app_dir} opraveno cíleným reinstallem"
      retry_fixed=$((retry_fixed+1))
    else
      fail "${app_dir} zůstává rozbité — $(dep_dir_health_message "$app_dir" "$post_health")"
      hint_classified "user-action" "local-only" "otevři konkrétní package/lockfile problém v ${app_dir}; doctor už nehlásí falešné OK"
      recheck_broken=$((recheck_broken+1))
    fi
  done < <(list_node_project_dirs)

  printf '\n  Re-check: %d projektů, %d cílených reinstallů, %d opraveno reinstallem, %d zůstává rozbitých\n' \
    "$recheck_total" "$retried" "$retry_fixed" "$recheck_broken"

  if [[ "$recheck_broken" -gt 0 ]]; then
    fail "deps-status není čistý"
    return 2
  fi

  ok "deps-status je čistý"
}

# --- Subcommand: install-launchpad (Linux helper) ---

install_launchpad_linux() {
  require_cmd bun

  local bun_bin
  bun_bin="$(command -v bun)"

  local contracts_dir="${ROOT_DIR}/launchpad/contracts"
  local app_dir="${ROOT_DIR}/launchpad/app/v1"

  if [[ ! -f "${contracts_dir}/package.json" ]] || [[ ! -f "${app_dir}/package.json" ]]; then
    fail "launchpad/contracts nebo launchpad/app/v1 chybí — nemůžu instalovat"
    return 2
  fi

  if (cd "$contracts_dir" && bun install --frozen-lockfile) >/dev/null; then
    ok "launchpad/contracts deps OK"
  else
    fail "bun install v launchpad/contracts selhal"
    return 2
  fi
  if (cd "$app_dir" && bun install --frozen-lockfile) >/dev/null; then
    ok "launchpad/app/v1 deps OK"
  else
    fail "bun install v launchpad/app/v1 selhal"
    return 2
  fi

  local xdg_data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
  local xdg_bin_home="${XDG_BIN_HOME:-${HOME}/.local/bin}"
  local apps_dir="${xdg_data_home}/applications"
  local icons_dir="${xdg_data_home}/icons/hicolor/scalable/apps"
  local launcher_path="${xdg_bin_home}/agentmint-launchpad-gen2"
  local desktop_path="${apps_dir}/agentmint-launchpad-gen2.desktop"
  local icon_path="${icons_dir}/agentmint-launchpad-gen2.svg"

  mkdir -p "$apps_dir" "$icons_dir" "$xdg_bin_home"

  cat >"$launcher_path" <<EOF
#!/usr/bin/env bash
# Generated by company/scripts/doctor.sh install-launchpad on $(date -u +%Y-%m-%dT%H:%M:%SZ).
# Workspace-bound launcher for AgentMint Launchpad GEN2 on Linux.
set -euo pipefail
WORKSPACE_ROOT="${ROOT_DIR}"
PORT="\${LAUNCHPAD_PORT:-8888}"
BUN_BIN="${bun_bin}"

cd "\${WORKSPACE_ROOT}/launchpad/app/v1"

if curl -fsS -o /dev/null "http://127.0.0.1:\${PORT}/" 2>/dev/null; then
  : # už běží
else
  nohup "\${BUN_BIN}" start >/tmp/agentmint-launchpad.log 2>&1 &
  disown || true
  for _ in \$(seq 1 50); do
    if curl -fsS -o /dev/null "http://127.0.0.1:\${PORT}/" 2>/dev/null; then
      break
    fi
    sleep 0.2
  done
fi

if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "http://127.0.0.1:\${PORT}/" >/dev/null 2>&1 || true
fi
EOF
  chmod 0755 "$launcher_path"

  cat >"$icon_path" <<'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="AgentMint Launchpad">
  <rect width="64" height="64" rx="14" fill="#2563eb"/>
  <path d="M20 22h24v20H20z" fill="#fff"/>
  <path d="M26 29h12M26 35h8" stroke="#2563eb" stroke-width="3" stroke-linecap="round"/>
  <path d="M18 46h28" stroke="#fff" stroke-width="5" stroke-linecap="round"/>
</svg>
SVGEOF

  cat >"$desktop_path" <<EOF
[Desktop Entry]
Type=Application
Name=AgentMint Launchpad GEN2
Comment=Local control plane for AgentMint Workspace GEN2
Exec=${launcher_path}
Icon=agentmint-launchpad-gen2
Terminal=false
Categories=Development;
StartupNotify=false
EOF
  chmod 0644 "$desktop_path"

  ok "launcher skript: ${launcher_path}"
  ok ".desktop entry: ${desktop_path}"
  ok "ikona: ${icon_path}"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
    ok "update-desktop-database proběhl"
  fi

  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache "${xdg_data_home}/icons/hicolor" >/dev/null 2>&1 || true
  fi

  case ":${PATH}:" in
    *":${xdg_bin_home}:"*)
      :
      ;;
    *)
      warn "${xdg_bin_home} není v PATH — Launchpad jde spustit přes Activities, ale ne z terminálu příkazem 'agentmint-launchpad-gen2'"
      hint "přidej '${xdg_bin_home}' do PATH v ~/.bashrc nebo ~/.zshrc"
      ;;
  esac
}

# --- Subcommand: install-launchpad ---

cmd_install_launchpad() {
  local dock=1
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_install_launchpad_usage
        return 0
        ;;
      --skip-dock) dock=0 ;;
      *)
        fail "doctor install-launchpad nezná argument: $arg"
        hint "spusť 'doctor install-launchpad --help'"
        return 2
        ;;
    esac
  done

  header "Launchpad GEN2 install"

  local uname_s
  uname_s="$(uname -s)"

  if [[ "$uname_s" == "Linux" ]]; then
    install_launchpad_linux
    return $?
  fi

  if [[ "$uname_s" != "Darwin" ]]; then
    printf '  [skip] install Launchpadu zatím jen pro macOS a Linux (Windows: použij `bun start` v launchpad/app/v1)\n'
    return 0
  fi

  require_cmd bun

  local installer="${ROOT_DIR}/launchpad/update-launchpad.sh"
  local app_path="${HOME}/Applications/AgentMint Launchpad GEN2.app"

  if [[ ! -x "$installer" ]]; then
    fail "Launchpad installer chybí nebo není spustitelný: ${installer}"
    hint "ověř checkout launchpad/ v super-repu"
    return 2
  fi

  if (cd "$ROOT_DIR" && bash "$installer"); then
    ok "Launchpad GEN2 app nainstalovaná"
  else
    fail "Launchpad GEN2 install selhal"
    hint "spusť ručně: bash launchpad/update-launchpad.sh"
    return 2
  fi

  if [[ -d "$app_path" ]]; then
    ok "${app_path} existuje"
  else
    fail "po instalaci chybí ${app_path}"
    return 2
  fi

  if [[ "$dock" -eq 1 ]]; then
    add_launchpad_to_dock "$app_path" || true
  else
    printf '  [skip] Dock update (--skip-dock)\n'
  fi

  local legacy_app="${HOME}/Applications/AgentMint Launchpad.app"
  if [[ -d "$legacy_app" ]]; then
    warn "legacy Launchpad app je stále nainstalovaná: ${legacy_app}"
    hint "po ověření GEN2 ji odinstaluj ručně"
  fi
}

# --- Subcommand: deps-status ---
# Strojově čitelný list Node projektů + health flag. Launchpad UI ho volá pro banner.

cmd_deps_status() {
  local json_mode=0
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        print_deps_status_usage
        return 0
        ;;
      --json) json_mode=1 ;;
      *)
        fail "doctor deps-status nezná argument: $arg"
        hint "spusť 'doctor deps-status --help'"
        return 2
        ;;
    esac
  done

  if [[ "$json_mode" -eq 1 ]]; then
    local first=1
    printf '{"apps":['
    while IFS= read -r app_dir; do
      [[ -z "$app_dir" ]] && continue
      local health needs
      health="$(dep_dir_health "$app_dir")"
      needs="false"
      if [[ "$health" != "ok" ]]; then needs="true"; fi
      if [[ "$first" -eq 1 ]]; then first=0; else printf ','; fi
      printf '{"path":"%s","needsInstall":%s,"status":"%s"}' "$app_dir" "$needs" "$health"
    done < <(list_node_project_dirs)
    printf ']}\n'
    return 0
  fi

  header "Node závislosti aplikací"
  local total=0 missing=0
  while IFS= read -r app_dir; do
    [[ -z "$app_dir" ]] && continue
    total=$((total+1))
    local health
    health="$(dep_dir_health "$app_dir")"
    if [[ "$health" != "ok" ]]; then
      missing=$((missing+1))
      warn "${app_dir} — $(dep_dir_health_message "$app_dir" "$health")"
    else
      ok "${app_dir}"
    fi
  done < <(list_node_project_dirs)
  printf '\n  Celkem: %d projektů — %d se zdravými závislostmi, %d potřebuje opravu\n' \
    "$total" "$((total-missing))" "$missing"
  if [[ "$missing" -gt 0 ]]; then
    hint "spusť 'doctor install-deps' pro nainstalování všeho najednou"
    return 1
  fi
}

# --- Dispatch ---

ensure_default_tool_paths
require_cmd git

SUBCMD="${1:-status}"
if [[ "$SUBCMD" == "-h" || "$SUBCMD" == "--help" ]]; then
  print_usage
  exit 0
fi
if [[ "$#" -gt 0 ]]; then shift; fi

if ! command -v jq >/dev/null 2>&1; then
  repair_coworker_tooling_local || true
fi
require_cmd jq

case "$SUBCMD" in
  status)            cmd_status "$@" ;;
  check)             cmd_check "$@" ;;
  repair-local)      cmd_repair_local "$@" ;;
  check-my-context)  cmd_check_my_context "$@" ;;
  workspace-tasks)   cmd_workspace_tasks "$@" ;;
  init)              cmd_init "$@" ;;
  sync)              cmd_sync "$@" ;;
  push)              cmd_push "$@" ;;
  install-deps)      cmd_install_deps "$@" ;;
  install-launchpad) cmd_install_launchpad "$@" ;;
  deps-status)       cmd_deps_status "$@" ;;
  pullable)          cmd_pullable "$@" ;;
  port)              cmd_port "$@" ;;
  *)
    printf 'Unknown subcommand: %s\n' "$SUBCMD" >&2
    print_usage >&2
    exit 2
    ;;
esac
