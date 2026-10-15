# AgentMint GEN2 doctor — health check, sync, push entry point pro Windows.
# macOS ekvivalent: doctor.sh (parita subcommandů + formátu výstupu).
#
# Subcommands:
#   doctor                — default: status
#   doctor status         — přehled modulů a stavu super-repa
#   doctor init           — první inicializace workspace po clone
#   doctor install-deps   — nainstaluje Launchpad runtime dependencies
#   doctor install-launchpad — nainstaluje Windows Launchpad zástupce + taskbar pin
#   doctor sync           — pull super-repa + sync nested repo modules
#   doctor sync --rebase  — navíc rebase lokálních commitů
#   doctor push "<msg>"   — commit + push dirty nested repo/root změn
#   doctor check          — full health check
#   doctor check --quick  — jen kritické checks
#   doctor check --template-placeholders — jen <VYPLNIT_*> placeholder sken
#   doctor check-my-context — co z kaskády AGENTS.md se na mě vztahuje
#   doctor workspace-tasks — validate TODO.tasks.json / DONE.tasks.json / ISSUES.open.json
#
# Dokumentace v company/scripts/README.md §Doctor.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent (Split-Path -Parent $scriptDir)
$manifestPath = Join-Path $rootDir "modules.manifest.json"
if (-not (Test-Path $manifestPath)) {
  $manifestPath = Join-Path $rootDir "company\scripts\modules.manifest.json"
}
$fixesDir = Join-Path $scriptDir "doctor\fixes"

# --- Output helpers ---

$script:warnCount = 0
$script:failCount = 0

function Write-Ok   { param($msg) Write-Host ("  [ok]   {0}" -f $msg) -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host ("  [warn] {0}" -f $msg) -ForegroundColor Yellow; $script:warnCount++ }
function Write-Fail { param($msg) Write-Host ("  [fail] {0}" -f $msg) -ForegroundColor Red; $script:failCount++ }
function Write-Hint { param($msg) Write-Host ("       > {0}" -f $msg) -ForegroundColor Cyan }
function Write-Header { param($msg) Write-Host ""; Write-Host ("== {0} ==" -f $msg) -ForegroundColor DarkGray }

function Show-Usage {
  Write-Host @"
Usage: doctor <command> [options]

Commands:
  status              Show workspace and module status
  init                Initialize nested repos and local Launchpad handoff
  install-deps        Install Launchpad runtime dependencies
  install-launchpad   Install Windows Launchpad shortcut and taskbar pin
  sync                Pull super-repo and sync safe nested repos
  push                Commit and push workspace changes
  check               Run health checks
  check --template-placeholders
                      Scan remaining <VYPLNIT_*> placeholders
  check-my-context    Show applicable AGENTS.md context
  workspace-tasks     Validate Git-native workspace task files

Run "doctor <command> --help" for command-specific help.
"@
}

function Show-InitUsage {
  Write-Host @"
Usage:
  doctor init [--skip-deps] [--skip-launchpad-install] [--skip-taskbar|--skip-dock] [--check|--no-check]

Initializes configured nested repos, optionally installs Launchpad runtime
dependencies, installs the Windows Launchpad handoff, and runs a final
doctor check.

Options:
  --skip-deps                Do not run doctor install-deps.
  --skip-launchpad-install   Do not create Launchpad shortcut/taskbar handoff.
  --skip-taskbar             Create Start Menu shortcut but do not update taskbar.
  --skip-dock                Alias for --skip-taskbar for cross-platform scripts.
  --check                    Run doctor check --quick after init (default).
  --no-check                 Skip final doctor check.
  -h, --help                 Show this help.

Side effects: may clone nested repos, run bun install, create user-local
Launchpad files under LOCALAPPDATA/APPDATA, and update the current user's
Windows taskbar layout.
"@
}

function Show-InstallDepsUsage {
  Write-Host @"
Usage:
  doctor install-deps

Installs the top-level Launchpad runtime dependencies with Bun.

Side effects: may create or update node_modules in Launchpad, Guide,
design-system, Mission Control, and nested repo app scopes. It must not rewrite
lockfiles; lockfile drift is reported as a manual fix.
"@
}

function Show-WorkspaceTasksUsage {
  Write-Host @"
Usage:
  doctor workspace-tasks

Validates Git-native workspace task files:
  - TODO.tasks.json for live executable work
  - DONE.tasks.json for completed or archived work
  - ISSUES.open.json for unresolved decisions

The validator also checks that any TODO.md next to a TODO.tasks.json is only a
legacy pointer and does not contain live Markdown checkbox tasks.

Side effects: none.

  -h, --help   Show this help.
"@
}

function Show-InstallLaunchpadUsage {
  Write-Host @"
Usage:
  doctor install-launchpad [--skip-taskbar|--skip-dock]

Creates a user-local Windows Launchpad launcher, Start Menu shortcut, and
taskbar handoff for this workspace.

Options:
  --skip-taskbar   Create launcher and Start Menu shortcut only.
  --skip-dock      Alias for --skip-taskbar for cross-platform scripts.
  -h, --help       Show this help.

Side effects: writes under LOCALAPPDATA/APPDATA and may refresh the Windows
shell taskbar layout for the current user.
"@
}

function Show-SyncUsage {
  Write-Host @"
Usage:
  doctor sync [--rebase]

Pulls the super-repo when the root working tree is clean and syncs safe,
clean nested repos from root modules.manifest.json (legacy fallback:
company/scripts/modules.manifest.json). Dirty nested
repos are skipped.

Options:
  --rebase     Use git pull --rebase for the super-repo instead of --ff-only.
  -h, --help   Show this help.

Side effects: may pull the super-repo and update safe nested repos.
"@
}

function Show-PushUsage {
  Write-Host @"
Usage:
  doctor push "<message>"

Commits and pushes dirty nested repo modules using the Windows flow.

Side effects: may commit and push. Prefer macOS doctor.sh for the current
scoped --module / --include workflow until PowerShell parity is completed.
"@
}

function Get-CommitMessageSubject {
  param([string]$message)
  return (($message -split "`r?`n", 2)[0]).Trim()
}

function Get-CommitMessageBodyLineCount {
  param([string]$message)
  $lines = $message -split "`r?`n"
  if ($lines.Length -le 1) { return 0 }
  return @($lines[1..($lines.Length - 1)] | Where-Object { $_.Trim().Length -gt 0 }).Count
}

function Add-CommitSubjectSuffix {
  param([string]$message, [string]$suffix)
  $subject = Get-CommitMessageSubject $message
  $parts = $message -split "`r?`n", 2
  if ($parts.Length -gt 1) {
    return ("{0}{1}`n{2}" -f $subject, $suffix, $parts[1])
  }
  return ("{0}{1}" -f $subject, $suffix)
}

function Test-CommitMessageQuality {
  param([string]$message)

  Write-Header "Commit message quality"

  $subject = Get-CommitMessageSubject $message
  $lower = $subject.ToLowerInvariant()
  $bodyLines = Get-CommitMessageBodyLineCount $message

  if (-not $subject) {
    Write-Fail "commit message subject je prázdný"
    return $false
  }

  if ($lower -in @("fix", "fixes", "update", "updates", "change", "changes", "cleanup", "wip", "misc", "stuff", "todo", "temp")) {
    Write-Fail ("commit message je příliš obecná: '{0}'" -f $subject)
    Write-Hint "použij tvar 'Area: konkrétní změna' a v těle doplň co/proč/dopad"
    return $false
  }

  if ($subject.Length -lt 12) {
    Write-Fail ("commit message subject je příliš krátký: '{0}'" -f $subject)
    Write-Hint "release notes z něj nepoznají, co se změnilo"
    return $false
  }

  if ($subject -notlike "*:*") {
    Write-Warn "subject nemá oblast před dvojtečkou"
    Write-Hint "doporučený tvar: 'Catalog: Remove invalid service package variant'"
  } else {
    Write-Ok "subject má oblast a konkrétní shrnutí"
  }

  if ($bodyLines -eq 0) {
    Write-Warn "commit message nemá tělo"
    Write-Hint "pro release notes doplň 1-3 odstavce: co se změnilo, proč, dopad/testy"
  } else {
    Write-Ok "message body má kontext pro release notes"
  }

  return $true
}

function Test-FirebaseMirrorDirty {
  $firebaseRoot = Join-Path $rootDir "modules\firebase"
  if (-not (Test-Path $firebaseRoot)) { return $false }
  $dirty = git -C $firebaseRoot status --porcelain -- mirror 2>$null
  return [bool]$dirty
}

function Require-Cmd {
  param($cmd)
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Host ("[fail] Missing required command: {0}" -f $cmd) -ForegroundColor Red
    exit 2
  }
}

function Add-DefaultToolPaths {
  if (Get-Command bun -ErrorAction SilentlyContinue) {
    return
  }

  $bunInstall = if ($env:BUN_INSTALL) { $env:BUN_INSTALL } else { Join-Path $HOME ".bun" }
  $bunBin = Join-Path $bunInstall "bin"
  $bunExe = Join-Path $bunBin "bun.exe"
  if (-not (Test-Path $bunExe)) {
    return
  }

  $env:BUN_INSTALL = $bunInstall
  $pathSeparator = [IO.Path]::PathSeparator
  $pathParts = @($env:PATH -split [Regex]::Escape($pathSeparator))
  if ($pathParts -notcontains $bunBin) {
    $env:PATH = "{0}{1}{2}" -f $bunBin, $pathSeparator, $env:PATH
  }
}

function Test-WindowsHost {
  return ($env:OS -eq "Windows_NT" -or [Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)
}

function Invoke-NativeQuiet {
  param([scriptblock]$Command)
  & $Command *> $null
  if ($null -eq $LASTEXITCODE) { return 0 }
  return $LASTEXITCODE
}

function ConvertTo-WindowsFileName {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Fallback = "Workspace"
  )

  $clean = $Name
  foreach ($char in [IO.Path]::GetInvalidFileNameChars()) {
    $clean = $clean.Replace([string]$char, "")
  }
  $clean = ($clean -replace '\s+', ' ').Trim(" .")
  if (-not $clean) { return $Fallback }
  return $clean
}

function Get-LaunchpadCompanyName {
  return "AgentMint"
}

function Get-LaunchpadSafeCompanyName {
  return (ConvertTo-WindowsFileName -Name (Get-LaunchpadCompanyName) -Fallback "Workspace")
}

function Get-LaunchpadAppName {
  return ("{0} Launchpad GEN2" -f (Get-LaunchpadCompanyName))
}

function Get-LaunchpadSafeAppName {
  return (ConvertTo-WindowsFileName -Name (Get-LaunchpadAppName) -Fallback "Workspace Launchpad GEN2")
}

function Get-LaunchpadWindowsInstallDir {
  return (Join-Path $env:LOCALAPPDATA ("Programs\{0}" -f (Get-LaunchpadSafeAppName)))
}

function Get-LaunchpadWindowsLauncherPath {
  return (Join-Path (Get-LaunchpadWindowsInstallDir) "launchpad.ps1")
}

function Get-WindowsPowerShellPath {
  $windowsPowerShell = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
  if (Test-Path $windowsPowerShell) { return $windowsPowerShell }
  return (Get-Process -Id $PID).Path
}

function Get-LaunchpadWindowsExeStem {
  $stem = ((Get-LaunchpadSafeAppName) -replace '[^A-Za-z0-9]+', '')
  if (-not $stem) { return "WorkspaceLaunchpadGEN2" }
  return $stem
}

# --- Manifest readers ---

function Test-ManifestSlotHasGitUrl {
  param($slot)
  if (-not $slot) { return $false }
  if ($slot.PSObject.Properties.Name -notcontains "git") { return $false }
  if (-not $slot.git) { return $false }
  if ($slot.git.PSObject.Properties.Name -notcontains "url") { return $false }
  return -not [string]::IsNullOrWhiteSpace([string]$slot.git.url)
}

function Get-ManifestSlot {
  param($path)
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  return $manifest.module_slots | Where-Object { $_.path -eq $path } | Select-Object -First 1
}

function Get-ManifestSubmodulePaths {
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  return $manifest.module_slots | ForEach-Object { $_.path }
}

function Get-ManifestModuleUrl {
  param($path)
  $slot = Get-ManifestSlot $path
  if (Test-ManifestSlotHasGitUrl $slot) { return [string]$slot.git.url }
  return ""
}

function Get-ManifestModuleBranch {
  param($path)
  $slot = Get-ManifestSlot $path
  if ($slot -and $slot.PSObject.Properties.Name -contains "git" -and $slot.git -and $slot.git.PSObject.Properties.Name -contains "branch" -and $slot.git.branch) {
    return [string]$slot.git.branch
  }
  return "main"
}

function Get-ActiveModulePaths {
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  return $manifest.module_slots |
    Where-Object { Test-ManifestSlotHasGitUrl $_ } |
    ForEach-Object { $_.path }
}

function Get-GitmodulePaths {
  # Compatibility name: these are active nested repo module paths from the
  # manifest, not .gitmodules entries.
  return Get-ActiveModulePaths
}

function Get-NodeProjectDirs {
  $dirs = New-Object System.Collections.Generic.List[string]

  foreach ($path in @("design-system/app", "guide/app", "launchpad/app/v1", "launchpad/contracts")) {
    $packageJson = Join-Path $rootDir (($path -replace '/', '\') + "\package.json")
    if (Test-Path $packageJson) { $dirs.Add($path) }
  }

  foreach ($repo in Get-GitmodulePaths) {
    foreach ($candidate in @("$repo/app", "$repo/app/v1")) {
      $packageJson = Join-Path $rootDir (($candidate -replace '/', '\') + "\package.json")
      if (Test-Path $packageJson) { $dirs.Add($candidate) }
    }
  }

  return $dirs | Sort-Object -Unique
}

function Get-ModuleState {
  param($path)
  if (-not (Get-ManifestModuleUrl $path)) { return "planned_slot" }
  $gitDir = Join-Path $rootDir "$path\.git"
  if (Test-Path $gitDir) { return "available" }
  return "missing_access"
}

function Test-IsForkModule {
  param($path)
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  $slot = $manifest.module_slots | Where-Object { $_.path -eq $path }
  if (-not $slot) { return $false }
  return ($null -ne $slot.fork_upstream)
}

function Get-SubmoduleDirty {
  param($path)
  $full = Join-Path $rootDir $path
  if (-not (Test-Path $full)) { return "-" }
  $status = git -C $full status --porcelain 2>$null
  if ([string]::IsNullOrEmpty($status)) { return "clean" } else { return "dirty" }
}

function Get-SubmoduleBranch {
  param($path)
  $full = Join-Path $rootDir $path
  $gitFile = Join-Path $full ".git"
  if (-not (Test-Path $gitFile)) { return "-" }
  $branch = git -C $full branch --show-current 2>$null
  if ([string]::IsNullOrEmpty($branch)) { return "HEAD" }
  return $branch
}

function Get-SubmoduleExpectedBranch {
  param($path)
  return (Get-ManifestModuleBranch $path)
}

function Get-RepoNonMainBranchReason {
  param($path, $branch = "")
  switch ($path) {
    "modules/monorepo" { return "task-driven PR workflow" }
    "modules/firmware" {
      if (-not $branch -or $branch -match '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9][A-Za-z0-9._-]*)?$') {
        return "firmware version branch workflow, např. 1.2.0 nebo 2.0.0-dev"
      }
      return $null
    }
    default { return $null }
  }
}

function Test-SubmoduleDeleteOnlyStatus {
  param([Parameter(Mandatory = $true)][string]$ModulePath)

  $statusLines = @(git -C $ModulePath status --porcelain 2>$null)
  if ($statusLines.Count -eq 0) { return $false }

  foreach ($line in $statusLines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $prefixLength = [Math]::Min(2, $line.Length)
    $prefix = $line.Substring(0, $prefixLength)
    if ($prefix -notin @(" D", "D ", "DD")) {
      return $false
    }
  }

  return $true
}

function Repair-EmptySubmoduleWorktree {
  param([Parameter(Mandatory = $true)][string]$Module)

  $modulePath = Join-Path $rootDir ($Module -replace '/', '\')
  if (-not (Test-Path $modulePath)) { return $false }
  if (-not (Test-Path (Join-Path $modulePath ".git"))) { return $false }

  $entries = @(Get-ChildItem -Force $modulePath | Where-Object { $_.Name -ne ".git" })
  if ($entries.Count -gt 0) { return $false }
  if (-not (Test-SubmoduleDeleteOnlyStatus -ModulePath $modulePath)) { return $false }

  try {
    git -C $modulePath restore --source=HEAD --staged --worktree . *> $null
    return $true
  } catch {
    return $false
  }
}

# --- Subcommand: status ---

function Invoke-Status {
  Write-Header "Super-repo"
  $superBranch = git -C $rootDir branch --show-current 2>$null
  if (-not $superBranch) { $superBranch = "detached" }
  $superDirty = (git -C $rootDir status --porcelain 2>$null | Measure-Object).Count
  $superRemote = git -C $rootDir remote get-url origin 2>$null
  if (-not $superRemote) { $superRemote = "(no origin)" }

  Write-Host ("  branch:   {0}" -f $superBranch)
  Write-Host ("  dirty:    {0} soubor(ů)" -f $superDirty)
  Write-Host ("  remote:   {0}" -f $superRemote)

  Write-Header "Moduly (podle manifestu)"
  $total = 0; $avail = 0; $missing = 0; $planned = 0; $dirty = 0

  foreach ($path in Get-ManifestSubmodulePaths) {
    $total++
    $state = Get-ModuleState $path
    $dirtyFlag = Get-SubmoduleDirty $path
    $branchFlag = Get-SubmoduleBranch $path
    $forkTag = ""
    if (Test-IsForkModule $path) { $forkTag = ", fork" }

    switch ($state) {
      "available" {
        $avail++
        if ($dirtyFlag -eq "dirty") {
          $dirty++
          Write-Warn ("{0}  (branch: {1}{2}, DIRTY)" -f $path, $branchFlag, $forkTag)
        } else {
          Write-Ok ("{0}  (branch: {1}{2})" -f $path, $branchFlag, $forkTag)
        }
      }
      "missing_access" {
        $missing++
        Write-Warn ("{0}  (missing_access — SSH přístup nebo spusť 'doctor sync')" -f $path)
      }
      "planned_slot" {
        $planned++
        Write-Host ("  [planned] {0}" -f $path)
      }
    }
  }

  Write-Host ""
  Write-Host ("  Celkem: {0} modulů — {1} available, {2} missing_access, {3} planned, {4} dirty" `
    -f $total, $avail, $missing, $planned, $dirty)
}

# --- Subcommand: check ---

function Invoke-Check {
  param([string[]]$opts)
  $quick = $opts -contains "--quick"
  $onlyTemplate = $opts -contains "--template-placeholders"

  if ($onlyTemplate) {
    Invoke-TemplatePlaceholderCheck
    _Write-CheckSummary
    return
  }

  Write-Header "Git setup"
  if (Test-Path (Join-Path $rootDir ".git")) {
    Write-Ok ("{0} je git repo" -f $rootDir)
  } else {
    Write-Fail ("{0} není git repo" -f $rootDir)
  }

  $superBranch = git -C $rootDir branch --show-current 2>$null
  if (-not $superBranch) {
    Write-Fail "super-repo je v detached HEAD"
    Write-Hint "spusť 'git checkout main'"
  } elseif ($superBranch -eq "main") {
    Write-Ok "super-repo na branchi main"
  } else {
    Write-Warn ("super-repo na branchi '{0}' (očekáváno: main)" -f $superBranch)
  }

  $remote = git -C $rootDir remote get-url origin 2>$null
  if ($remote) {
    Write-Ok ("origin remote nastaven: {0}" -f $remote)
  } else {
    Write-Warn "origin remote není nastaven"
    Write-Hint "očekáváno: git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git"
  }

  Write-Header "Claude Code entrypoint"
  $claudeEntrypoint = Join-Path $rootDir "CLAUDE.md"
  if (Test-Path $claudeEntrypoint) {
    Write-Ok "CLAUDE.md existuje"
    $claudeText = Get-Content $claudeEntrypoint -Raw
    if (($claudeText -match "AGENTS\.md") -and ($claudeText -match "check-my-context")) {
      Write-Ok "CLAUDE.md odkazuje na AGENTS.md a preflight"
    } else {
      Write-Fail "CLAUDE.md neobsahuje odkaz na AGENTS.md nebo check-my-context"
      Write-Hint "drž CLAUDE.md jako tenký Claude Code bootstrap na root AGENTS.md"
    }
  } else {
    Write-Fail "CLAUDE.md chybí; Claude Code nemá nativní GEN2 bootstrap"
    Write-Hint "vytvoř CLAUDE.md jako krátký odkaz na AGENTS.md a doctor check-my-context"
  }

  Write-Header "Skills entrypointy"
  $claudeSkills = Join-Path $rootDir ".claude\skills"
  $codexSkills = Join-Path $rootDir ".agents\skills"
  if (Test-Path $claudeSkills) {
    Write-Ok ".claude/skills existuje (source of truth)"
  } else {
    Write-Fail ".claude/skills chybí"
  }

  if (Test-Path $codexSkills) {
    $item = Get-Item $codexSkills -Force
    if ($item.LinkType -eq "SymbolicLink") {
      $target = $item.Target
      if ($target -match '\.claude[\\/]skills$') {
        Write-Ok ".agents/skills je symlink na .claude/skills"
      } else {
        Write-Warn (".agents/skills je symlink, ale míří na {0}" -f $target)
        Write-Hint "očekáváno: .agents/skills -> ../.claude/skills"
      }
    } else {
      Write-Fail ".agents/skills není symlink; hrozí drift mezi Claude a Codex skills"
      Write-Hint "nahraď ho symlinkem na .claude/skills"
    }
  } else {
    Write-Fail ".agents/skills chybí; Codex neuvidí workspace skills"
    Write-Hint "vytvoř symlink .agents/skills -> ../.claude/skills"
  }

  $skillCount = 0
  if (Test-Path $claudeSkills) {
    $skillCount = @(Get-ChildItem $claudeSkills -Directory -ErrorAction SilentlyContinue |
      Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }).Count
  }
  if ($skillCount -gt 0) {
    Write-Ok ("{0} sdílených skillů v Git knihovně" -f $skillCount)
  } else {
    Write-Warn "nenalezen žádný SKILL.md v .claude/skills"
  }

  Write-Header "Agent CLI tooling"
  $codexCommand = Get-Command codex -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($codexCommand) {
    $codexVersion = & codex --version 2>&1 | Select-Object -First 1
    if ($codexVersion) {
      Write-Ok ("codex v PATH ({0}, {1})" -f $codexCommand.Definition, $codexVersion)
    } else {
      Write-Ok ("codex v PATH ({0})" -f $codexCommand.Definition)
    }
  } else {
    Write-Warn "codex není v PATH"
    Write-Hint "agent initialization musí nastavit OpenAI Codex CLI tak, aby fungoval příkaz 'codex' v novém shellu"
    Write-Hint "přidej adresář s codex.exe do User PATH; lokální absolutní cestu necommituj do workspace"
  }

  Write-Header "Nested repo manifest"
  $gmPath = Join-Path $rootDir ".gitmodules"
  if (Test-Path $gmPath) {
    Write-Fail ".gitmodules existuje; AgentMint používá manifest-only nested repo model"
    Write-Hint "odstraň .gitmodules a netrackuj nested repa jako gitlink pointery"
  } else {
    Write-Ok ".gitmodules neexistuje"
  }

  $gitlinkLines = @(git -C $rootDir ls-files -s 2>$null | Where-Object { $_ -match '^160000\s' })
  if ($gitlinkLines.Count -gt 0) {
    Write-Fail "super-repo trackuje 160000 gitlink pointer"
    $gitlinkLines | ForEach-Object { Write-Hint $_ }
  } else {
    Write-Ok "super-repo netrackuje nested repo gitlink pointery"
  }

  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  $activeSlots = @($manifest.module_slots | Where-Object { Test-ManifestSlotHasGitUrl $_ })
  $plannedSlots = @($manifest.module_slots | Where-Object { -not (Test-ManifestSlotHasGitUrl $_) })
  if ($activeSlots.Count -gt 0) {
    Write-Ok ("{0} active nested repo slotů s git.url" -f $activeSlots.Count)
  } else {
    Write-Warn "manifest nemá žádný active nested repo slot s git.url"
  }
  if ($plannedSlots.Count -gt 0) {
    Write-Host ("  [info] {0} planned slotů bez git.url" -f $plannedSlots.Count)
  }

  foreach ($slot in $activeSlots) {
    if ($slot.git.PSObject.Properties.Name -notcontains "branch" -or -not $slot.git.branch) {
      Write-Warn ("{0}: chybí git.branch, používám main" -f $slot.path)
    } elseif ($slot.git.branch -eq "main") {
      Write-Ok ("{0}: branch main" -f $slot.path)
    } else {
      Write-Warn ("{0}: branch '{1}' (baseline je obvykle main)" -f $slot.path, $slot.git.branch)
    }
  }

  Write-Header "Repo branch health"
  $branchIssues = 0
  foreach ($path in $gitmodulePaths) {
    $state = Get-ModuleState $path
    if ($state -ne "available") { continue }

    $branch = Get-SubmoduleBranch $path
    $expected = Get-SubmoduleExpectedBranch $path

    if ($branch -eq "HEAD") {
      $branchIssues++
      Write-Fail ("{0}: detached HEAD (očekáváno: {1})" -f $path, $expected)
      Write-Hint ("spusť 'doctor sync' — clean nested repo moduly přepne zpět na {0}" -f $expected)
      continue
    }

    if ($branch -ne $expected) {
      $reason = Get-RepoNonMainBranchReason $path $branch
      if ($reason) {
        Write-Ok ("{0}: větev '{1}' je povolená ({2}; manifest baseline: {3})" -f $path, $branch, $reason, $expected)
      } else {
        $branchIssues++
        Write-Warn ("{0}: větev '{1}' (očekáváno: {2})" -f $path, $branch, $expected)
        Write-Hint ("ověř, jestli je jiná větev záměrná; jinak přepni na {0}" -f $expected)
      }
    }
  }
  if ($branchIssues -eq 0) {
    Write-Ok "všechny dostupné nested repo moduly jsou na očekávané větvi nebo povoleném workflow"
  }

  Write-Header "Fork nested repo moduly"
  # Každý fork (modul s fork_upstream polem) musí mít: origin, upstream,
  # <parent>-origin remoty a rerere.enabled=true. Viz ARCHITECTURE §19.
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  $forks = $manifest.module_slots | Where-Object { $_.fork_upstream }
  if (-not $forks) {
    Write-Host "  [info] žádný fork modul v manifestu"
  } else {
    foreach ($fork in $forks) {
      $forkPath = $fork.path
      $forkDir = Join-Path $rootDir ($forkPath -replace '/', '\')
      $gitMarker = Join-Path $forkDir ".git"
      if (-not (Test-Path $gitMarker)) {
        Write-Host ("  [skip] {0} neexistuje lokálně (není init)" -f $forkPath)
        continue
      }

      $mirror = $fork.fork_upstream.mirror
      $source = $fork.fork_upstream.source
      $parentName = [IO.Path]::GetFileNameWithoutExtension($mirror)

      $upstreamUrl = git -C $forkDir remote get-url upstream 2>$null
      if ($upstreamUrl -eq $mirror) {
        Write-Ok ("{0}: upstream -> {1}" -f $forkPath, $mirror)
      } else {
        Write-Warn ("{0}: upstream remote != {1} (aktuální: {2})" -f $forkPath, $mirror, ($upstreamUrl -or '<chybí>'))
        Write-Hint ("git -C {0} remote add upstream {1}" -f $forkPath, $mirror)
      }

      $parentUrl = git -C $forkDir remote get-url "$parentName-origin" 2>$null
      if ($parentUrl -eq $source) {
        Write-Ok ("{0}: {1}-origin -> {2}" -f $forkPath, $parentName, $source)
      } else {
        Write-Warn ("{0}: {1}-origin != {2} (aktuální: {3})" -f $forkPath, $parentName, $source, ($parentUrl -or '<chybí>'))
        Write-Hint ("git -C {0} remote add {1}-origin {2}" -f $forkPath, $parentName, $source)
      }

      $rerere = git -C $forkDir config --get rerere.enabled 2>$null
      if ($rerere -eq "true") {
        Write-Ok ("{0}: rerere.enabled=true" -f $forkPath)
      } else {
        Write-Warn ("{0}: rerere.enabled není true — kritické pro fork rebase" -f $forkPath)
        Write-Hint ("git -C {0} config rerere.enabled true" -f $forkPath)
      }
    }
  }

  if ($quick) {
    Write-Header "Quick mode — přeskakuji SSH/MCP/dependency checks"
    _Write-CheckSummary
    return
  }

  Write-Header "SSH přístup"
  $remote = git -C $rootDir remote get-url origin 2>$null
  if ($remote) {
    $sshResult = ssh -T -o StrictHostKeyChecking=accept-new -o BatchMode=yes git@github.com 2>&1
    if ($sshResult -match "successfully authenticated") {
      Write-Ok "SSH na github.com funguje"
    } else {
      Write-Warn "SSH na github.com neodpověděl očekávanou hláškou"
      Write-Hint "ověř 'ssh -T git@github.com' ručně"
    }
  } else {
    Write-Warn "SSH remote check přeskočen — workspace nemá origin remote"
    Write-Hint "očekáváno: git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git"
  }

  Write-Header "OS tooling"
  foreach ($tool in @("git", "jq", "bun", "node")) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
      $version = & $tool --version 2>&1 | Select-Object -First 1
      Write-Ok ("{0} dostupný ({1})" -f $tool, $version)
    } else {
      Write-Warn ("{0} není v PATH" -f $tool)
      Write-Hint "viz fixes/tooling-missing.md"
    }
  }

  Invoke-WorkspaceTasks -NoSummary

  Write-Header "Launchpad runtime"
  $lpPath = Join-Path $rootDir "launchpad\app\v1"
  if (Test-Path $lpPath) {
    Write-Ok "launchpad/app/v1/ existuje (in-tree GEN2)"
  } else {
    Write-Warn "launchpad/app/v1/ neexistuje"
  }

  Write-Header "MCP konfigurace (per-person)"
  $userSettings = Join-Path $env:USERPROFILE ".claude\settings.json"
  if (Test-Path $userSettings) {
    Write-Ok "~/.claude/settings.json existuje"
  } else {
    Write-Warn "~/.claude/settings.json neexistuje (žádný user-level MCP)"
  }
  Write-Hint "MCP secrets MUSÍ zůstat mimo Git. Viz root AGENTS.md §5."

  _Write-CheckSummary
}

function Invoke-TemplatePlaceholderCheck {
  Write-Header "Template placeholders"

  $matches = Get-ChildItem $rootDir -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch '[\\/]\.git[\\/]' -and
      $_.FullName -notmatch '[\\/]node_modules[\\/]' -and
      $_.FullName -notmatch '[\\/]target[\\/]' -and
      $_.FullName -notmatch '[\\/]dist[\\/]' -and
      $_.Name -notin @('TEMPLATE.md', 'TEMPLATE_CHANGELOG.md', 'TEMPLATE_VERSION')
    } |
    Select-String -Pattern '<VYPLNIT_[A-Z_]+>' -ErrorAction SilentlyContinue

  if (-not $matches) {
    Write-Ok "žádné <VYPLNIT_*> placeholdery nezbývají — production-ready"
    return
  }

  $files = @($matches | ForEach-Object { $_.Path } | Sort-Object -Unique)
  Write-Warn ("zbývá {0} výskyt(ů) <VYPLNIT_*> ve {1} soubor(ech)" -f @($matches).Count, $files.Count)

  foreach ($group in ($matches | Group-Object Path)) {
    $rel = Resolve-Path -Path $group.Name -Relative
    Write-Host ("    {0}" -f $rel)
    foreach ($match in $group.Group) {
      $placeholder = [regex]::Match($match.Line, '<VYPLNIT_[A-Z_]+>').Value
      Write-Host ("       L{0,-4}  {1}" -f $match.LineNumber, $placeholder)
    }
  }

  Write-Hint "vyplň placeholdery a spusť 'doctor check --template-placeholders' znovu"
  Write-Hint "vodítka viz .claude/skills/setup-from-template/SKILL.md — Krok 2"
}

function _Write-Summary {
  param([string]$label = "Check")
  Write-Host ""
  if ($script:failCount -gt 0) {
    Write-Host ("{0} complete: {1} fail, {2} warn." -f $label, $script:failCount, $script:warnCount) -ForegroundColor Red
    exit 2
  } elseif ($script:warnCount -gt 0) {
    Write-Host ("{0} complete: {1} warn." -f $label, $script:warnCount) -ForegroundColor Yellow
    Write-Host "Doctor doporučuje projít hints."
    exit 1
  } else {
    Write-Host ("{0} complete: vše v pořádku." -f $label) -ForegroundColor Green
  }
}

function _Write-CheckSummary { _Write-Summary -label "Check" }
function _Write-SyncSummary  { _Write-Summary -label "Sync" }
function _Write-PushSummary  { _Write-Summary -label "Push" }

# --- Subcommand: check-my-context ---

function Invoke-CheckMyContext {
  $pwdAbs = (Get-Location).Path

  Write-Header "Kontextový scope"
  Write-Host ("  pwd: {0}" -f $pwdAbs)

  $agentsRoot = Join-Path $rootDir "AGENTS.md"
  if (Test-Path $agentsRoot) {
    Write-Ok ("root AGENTS.md: {0}" -f $agentsRoot)
  } else {
    Write-Warn "root AGENTS.md chybí"
  }

  if ($pwdAbs -like (Join-Path $rootDir "company\team\*")) {
    $relative = $pwdAbs.Substring($rootDir.Length + 1)
    $parts = $relative -split [IO.Path]::DirectorySeparatorChar
    if ($parts.Length -ge 3) {
      $personDir = Join-Path $rootDir ("company\team\" + $parts[2])
      $personAgents = Join-Path $personDir "AGENTS.md"
      if (Test-Path $personAgents) {
        Write-Ok ("person overlay: {0}" -f $personAgents)
      } else {
        Write-Warn ("person overlay {0} chybí" -f $personAgents)
      }
    }
  }

  if ($pwdAbs -like (Join-Path $rootDir "modules\*")) {
    $relative = $pwdAbs.Substring($rootDir.Length + 1)
    $parts = $relative -split [IO.Path]::DirectorySeparatorChar
    if ($parts.Length -ge 2) {
      $moduleRoot = Join-Path $rootDir ("modules\" + $parts[1])
      $moduleAgents = Join-Path $moduleRoot "AGENTS.md"
      if (Test-Path $moduleAgents) {
        Write-Ok ("module AGENTS: {0}" -f $moduleAgents)
      } else {
        Write-Host ("  [info] module AGENTS: {0} neexistuje (OK, ne všechny moduly ho mají)" -f $moduleAgents)
      }
    }
  }

  Write-Header "Role"
  Write-Host "  Rozhodnutí o aktivní roli dělá uživatel nebo osobní AGENTS.md."
  Write-Host ("  Role definice: ls {0}\company\roles\" -f $rootDir)

  Write-Header "Skills"
  Write-Host ("  Sdílené source of truth: {0}\.claude\skills\" -f $rootDir)
  Write-Host ("  Claude Code entrypoint:  {0}\CLAUDE.md -> AGENTS.md" -f $rootDir)
  Write-Host ("  Codex entrypoint:        {0}\.agents\skills -> ..\.claude\skills" -f $rootDir)
  Write-Host ("  Osobní Git-tracked:      {0}\company\team\<ty>\.claude\skills\" -f $rootDir)

  Write-Host ""
  Write-Host "  Detail kaskády: root AGENTS.md §1 a §12."
}

function Invoke-WorkspaceTasks {
  param([switch]$NoSummary)

  Write-Header "Workspace task files"

  if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Warn "node není v PATH, přeskakuji workspace task validaci"
    Write-Hint "nainstaluj Node a spusť 'doctor workspace-tasks'"
    if (-not $NoSummary) { _Write-Summary -label "Workspace tasks" }
    return
  }

  $scriptPath = Join-Path $rootDir "company\scripts\check-workspace-tasks.mjs"
  if (-not (Test-Path $scriptPath)) {
    Write-Fail ("task validator chybí: {0}" -f $scriptPath)
    if (-not $NoSummary) { _Write-Summary -label "Workspace tasks" }
    return
  }

  Push-Location $rootDir
  try {
    node company/scripts/check-workspace-tasks.mjs
    if ($LASTEXITCODE -eq 0) {
      Write-Ok "Git-native task soubory jsou validní"
    } else {
      Write-Fail "Git-native task soubory nejsou validní"
      Write-Hint "spusť 'doctor workspace-tasks' a oprav uvedené TODO/DONE/ISSUES JSON soubory"
    }
  } finally {
    Pop-Location
  }

  if (-not $NoSummary) { _Write-Summary -label "Workspace tasks" }
}

# --- Subcommand: install-deps ---

function Invoke-InstallDeps {
  param([string[]]$opts, [switch]$NoSummary)

  if ($opts -contains "--help" -or $opts -contains "-h") {
    Show-InstallDepsUsage
    return
  }

  foreach ($opt in $opts) {
    Write-Fail ("doctor install-deps nezná argument: {0}" -f $opt)
    Write-Hint "spusť 'doctor install-deps --help'"
    if (-not $NoSummary) { _Write-Summary -label "Install deps" }
    return
  }

  Write-Header "Node dependencies"
  Add-DefaultToolPaths
  Require-Cmd bun

  $total = 0
  $installed = 0
  $failed = 0
  foreach ($appDir in Get-NodeProjectDirs) {
    $total++
    $fullDir = Join-Path $rootDir ($appDir -replace '/', '\')
    Write-Host ("  -> {0}" -f $appDir)
    Push-Location $fullDir
    try {
      $rc = Invoke-NativeQuiet { bun install --frozen-lockfile }
      if ($rc -eq 0) {
        Write-Ok ("{0} dependencies jsou nainstalované" -f $appDir)
        $installed++
      } else {
        Write-Fail ("bun install --frozen-lockfile selhal v {0}" -f $appDir)
        Write-Hint "nepřepisuj lockfile naslepo; ověř bun.lock a package.json"
        $failed++
      }
    } finally {
      Pop-Location
    }
  }

  Write-Host ""
  Write-Host ("  Celkem: {0} projektů — {1} nainstalováno, {2} selhalo" -f $total, $installed, $failed)
  if (-not $NoSummary) { _Write-Summary -label "Install deps" }
}

# --- Launchpad local installer helpers ---

function New-WindowsShortcut {
  param(
    [Parameter(Mandatory = $true)][string]$ShortcutPath,
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [string]$Arguments = "",
    [string]$WorkingDirectory = "",
    [string]$IconLocation = ""
  )

  $parent = Split-Path -Parent $ShortcutPath
  New-Item -ItemType Directory -Force -Path $parent | Out-Null

  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($ShortcutPath)
  $shortcut.TargetPath = $TargetPath
  $shortcut.Arguments = $Arguments
  if ($WorkingDirectory) { $shortcut.WorkingDirectory = $WorkingDirectory }
  if ($IconLocation) { $shortcut.IconLocation = $IconLocation }
  $shortcut.Description = Get-LaunchpadAppName
  $shortcut.Save()
}

function New-LaunchpadWindowsLauncher {
  $installDir = Get-LaunchpadWindowsInstallDir
  New-Item -ItemType Directory -Force -Path $installDir | Out-Null

  $launcherPath = Get-LaunchpadWindowsLauncherPath
  $content = @'
$ErrorActionPreference = "Stop"

$workspaceRoot = '__WORKSPACE_ROOT__'
$launchpadDir = Join-Path $workspaceRoot "launchpad\app\v1"
$logDir = Join-Path $env:LOCALAPPDATA "__SAFE_COMPANY_NAME__\Launchpad\logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$env:LAUNCHPAD_WORKSPACE_ROOT = $workspaceRoot
$env:BUN_INSTALL = if ($env:BUN_INSTALL) { $env:BUN_INSTALL } else { Join-Path $HOME ".bun" }
$bunBin = Join-Path $env:BUN_INSTALL "bin"
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = (@($bunBin, $machinePath, $userPath, $env:Path) | Where-Object { $_ }) -join [IO.Path]::PathSeparator

function Get-ConfiguredLaunchpadPort {
  $configuredPort = ""
  $envLocal = Join-Path $launchpadDir ".env.local"
  if (Test-Path $envLocal) {
    foreach ($line in Get-Content $envLocal) {
      if ($line -match '^\s*LAUNCHPAD_PORT\s*=\s*["'']?([0-9]+)["'']?\s*$') {
        $configuredPort = $Matches[1]
        break
      }
    }
  }

  $candidate = if ($env:LAUNCHPAD_PORT) { $env:LAUNCHPAD_PORT } elseif ($configuredPort) { $configuredPort } else { "8888" }
  $portNumber = 0
  if ([int]::TryParse($candidate, [ref]$portNumber) -and $portNumber -ge 1 -and $portNumber -le 65535) {
    return $portNumber
  }
  return 8888
}

$launchpadPort = Get-ConfiguredLaunchpadPort
$env:LAUNCHPAD_PORT = [string]$launchpadPort
$healthUrl = "http://127.0.0.1:$launchpadPort/health"
$uiUrl = "http://localhost:$launchpadPort"

function Test-LaunchpadHealth {
  try {
    $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2
    return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
  } catch {
    return $false
  }
}

if (Test-LaunchpadHealth) {
  Start-Process $uiUrl
  exit 0
}

if (-not (Test-Path $launchpadDir)) {
  Add-Content -Path (Join-Path $logDir "launcher.log") -Value "Launchpad directory not found: $launchpadDir"
  exit 1
}

$bunCommand = Get-Command bun -ErrorAction SilentlyContinue
if (-not $bunCommand) {
  Add-Content -Path (Join-Path $logDir "launcher.log") -Value "bun not found in PATH"
  exit 1
}

$stdout = Join-Path $logDir "launchpad.out.log"
$stderr = Join-Path $logDir "launchpad.err.log"
Start-Process -FilePath $bunCommand.Source -ArgumentList @("run", "start") -WorkingDirectory $launchpadDir -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr

for ($i = 0; $i -lt 20; $i++) {
  if (Test-LaunchpadHealth) {
    Start-Process $uiUrl
    exit 0
  }
  Start-Sleep -Milliseconds 500
}

Start-Process $uiUrl
'@

  $content = $content.Replace("__WORKSPACE_ROOT__", $rootDir.Replace("'", "''"))
  $content = $content.Replace("__SAFE_COMPANY_NAME__", (Get-LaunchpadSafeCompanyName))
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [IO.File]::WriteAllText($launcherPath, $content, $utf8NoBom)
  return $launcherPath
}

function Set-UInt16LE {
  param([byte[]]$Bytes, [int]$Offset, [int]$Value)
  $Bytes[$Offset] = [byte]($Value -band 0xff)
  $Bytes[$Offset + 1] = [byte](($Value -shr 8) -band 0xff)
}

function Set-UInt32LE {
  param([byte[]]$Bytes, [int]$Offset, [int64]$Value)
  $Bytes[$Offset] = [byte]($Value -band 0xff)
  $Bytes[$Offset + 1] = [byte](($Value -shr 8) -band 0xff)
  $Bytes[$Offset + 2] = [byte](($Value -shr 16) -band 0xff)
  $Bytes[$Offset + 3] = [byte](($Value -shr 24) -band 0xff)
}

function New-LaunchpadWindowsIcon {
  $installDir = Get-LaunchpadWindowsInstallDir
  New-Item -ItemType Directory -Force -Path $installDir | Out-Null

  $iconPath = Join-Path $installDir ("{0}.ico" -f (Get-LaunchpadWindowsExeStem))
  $size = 32
  $xorSize = $size * $size * 4
  $maskStride = [int]([Math]::Ceiling($size / 32.0) * 4)
  $maskSize = $maskStride * $size
  $imageSize = 40 + $xorSize + $maskSize
  $imageOffset = 6 + 16
  $bytes = New-Object byte[] ($imageOffset + $imageSize)

  Set-UInt16LE -Bytes $bytes -Offset 0 -Value 0
  Set-UInt16LE -Bytes $bytes -Offset 2 -Value 1
  Set-UInt16LE -Bytes $bytes -Offset 4 -Value 1
  $bytes[6] = [byte]$size
  $bytes[7] = [byte]$size
  $bytes[8] = 0
  $bytes[9] = 0
  Set-UInt16LE -Bytes $bytes -Offset 10 -Value 1
  Set-UInt16LE -Bytes $bytes -Offset 12 -Value 32
  Set-UInt32LE -Bytes $bytes -Offset 14 -Value $imageSize
  Set-UInt32LE -Bytes $bytes -Offset 18 -Value $imageOffset

  Set-UInt32LE -Bytes $bytes -Offset $imageOffset -Value 40
  Set-UInt32LE -Bytes $bytes -Offset ($imageOffset + 4) -Value $size
  Set-UInt32LE -Bytes $bytes -Offset ($imageOffset + 8) -Value ($size * 2)
  Set-UInt16LE -Bytes $bytes -Offset ($imageOffset + 12) -Value 1
  Set-UInt16LE -Bytes $bytes -Offset ($imageOffset + 14) -Value 32
  Set-UInt32LE -Bytes $bytes -Offset ($imageOffset + 16) -Value 0
  Set-UInt32LE -Bytes $bytes -Offset ($imageOffset + 20) -Value ($xorSize + $maskSize)

  $pixelStart = $imageOffset + 40
  for ($y = 0; $y -lt $size; $y++) {
    $dibY = $size - 1 - $y
    for ($x = 0; $x -lt $size; $x++) {
      $p = $pixelStart + (($dibY * $size + $x) * 4)
      $isGlyph = (($x -ge 9 -and $x -le 13 -and $y -ge 7 -and $y -le 24) -or ($x -ge 9 -and $x -le 24 -and $y -ge 20 -and $y -le 24))
      if ($isGlyph) {
        $bytes[$p] = 255
        $bytes[$p + 1] = 255
        $bytes[$p + 2] = 255
        $bytes[$p + 3] = 255
      } else {
        $bytes[$p] = 194
        $bytes[$p + 1] = 101
        $bytes[$p + 2] = 31
        $bytes[$p + 3] = 255
      }
    }
  }

  [IO.File]::WriteAllBytes($iconPath, $bytes)
  return $iconPath
}

function New-LaunchpadWindowsExecutable {
  param(
    [Parameter(Mandatory = $true)][string]$LauncherPath,
    [string]$IconPath = ""
  )

  $installDir = Get-LaunchpadWindowsInstallDir
  $exeStem = Get-LaunchpadWindowsExeStem
  $exePath = Join-Path $installDir ("{0}.exe" -f $exeStem)
  $sourcePath = Join-Path $installDir ("{0}.cs" -f $exeStem)
  $launcherRelativePath = "Programs\{0}\launchpad.ps1" -f (Get-LaunchpadSafeAppName)
  $source = @'
using System;
using System.Diagnostics;
using System.IO;

public static class WorkspaceLaunchpadGEN2
{
    [STAThread]
    public static void Main()
    {
        string launcherPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            @"__LAUNCHER_RELATIVE_PATH__"
        );
        string powerShellPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.Windows),
            @"System32\WindowsPowerShell\v1.0\powershell.exe"
        );

        if (!File.Exists(launcherPath) || !File.Exists(powerShellPath))
        {
            return;
        }

        var startInfo = new ProcessStartInfo();
        startInfo.FileName = powerShellPath;
        startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + launcherPath + "\"";
        startInfo.UseShellExecute = false;
        startInfo.CreateNoWindow = true;
        startInfo.WindowStyle = ProcessWindowStyle.Hidden;
        Process.Start(startInfo);
    }
}
'@

  $source = $source.Replace("__LAUNCHER_RELATIVE_PATH__", $launcherRelativePath)

  try {
    if (Test-Path $exePath) {
      Remove-Item -LiteralPath $exePath -Force
    }

    $compiledWithCsc = $false
    if ($IconPath -and (Test-Path $IconPath)) {
      $cscPath = Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"
      if (-not (Test-Path $cscPath)) {
        $cscPath = Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe"
      }

      if (Test-Path $cscPath) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [IO.File]::WriteAllText($sourcePath, $source, $utf8NoBom)
        $compileRc = Invoke-NativeQuiet {
          & $cscPath "/nologo" "/target:winexe" "/out:$exePath" "/win32icon:$IconPath" $sourcePath
        }
        $compiledWithCsc = ($compileRc -eq 0 -and (Test-Path $exePath))
      }
    }

    if (-not $compiledWithCsc) {
      Add-Type -TypeDefinition $source -OutputAssembly $exePath -OutputType WindowsApplication -ErrorAction Stop
    }

    if (Test-Path $exePath) {
      return $exePath
    }
  } catch {
    Write-Warn "nepodařilo se vytvořit .exe Launchpad launcher; zůstávám u PowerShell zástupce"
    Write-Hint $_.Exception.Message
  }

  return $null
}

function Add-LaunchpadShortcutToTaskbar {
  param([Parameter(Mandatory = $true)][string]$ShortcutPath)

  $shortcutName = Split-Path -Leaf $ShortcutPath
  $taskbarDir = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
  New-Item -ItemType Directory -Force -Path $taskbarDir | Out-Null

  $taskbarShortcut = Join-Path $taskbarDir $shortcutName
  Copy-Item -LiteralPath $ShortcutPath -Destination $taskbarShortcut -Force

  $pinVerbUsed = $false
  try {
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Split-Path -Parent $ShortcutPath))
    $item = $folder.ParseName($shortcutName)
    if ($item) {
      try {
        $item.InvokeVerb("taskbarpin")
        $pinVerbUsed = $true
      } catch {
      }

      if (-not $pinVerbUsed) {
        foreach ($verb in @($item.Verbs())) {
          $verbName = (($verb.Name -replace '&', '')).ToLowerInvariant()
          if ($verbName -match 'unpin|odepnout') { continue }
          if ($verbName -match 'taskbar|hlavn|připnout|pripnout') {
            $verb.DoIt()
            $pinVerbUsed = $true
            break
          }
        }
      }
    }
  } catch {
  }

  $ie4uinit = Join-Path $env:WINDIR "System32\ie4uinit.exe"
  if (Test-Path $ie4uinit) {
    Start-Process -FilePath $ie4uinit -ArgumentList "-show" -WindowStyle Hidden -Wait
  }

  $shellDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Shell"
  New-Item -ItemType Directory -Force -Path $shellDir | Out-Null
  $layoutPath = Join-Path $shellDir "LayoutModification.xml"
  $escapedShortcutPath = [Security.SecurityElement]::Escape($ShortcutPath)
  $layoutXml = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
  xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
  xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
  xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
  xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
  Version="1">
  <CustomTaskbarLayoutCollection>
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationLinkPath="$escapedShortcutPath" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [IO.File]::WriteAllText($layoutPath, $layoutXml, $utf8NoBom)

  $defaultLayoutsCache = Join-Path $shellDir "DefaultLayouts"
  if (Test-Path $defaultLayoutsCache) {
    Remove-Item -LiteralPath $defaultLayoutsCache -Recurse -Force -ErrorAction SilentlyContinue
  }

  if ($pinVerbUsed) {
    Write-Ok "Launchpad zástupce připnutý na taskbar přes Windows shell"
  } else {
    Write-Ok ("Launchpad taskbar layout připraven: {0}" -f $layoutPath)
  }
  Write-Hint "pokud ikona ještě není vidět, odhlaš/přihlaš se nebo restartuj Explorer; viz fixes/windows-launchpad-taskbar.md"
}

function Invoke-InstallLaunchpad {
  param([string[]]$opts, [switch]$NoSummary)

  $pinTaskbar = $true
  foreach ($opt in $opts) {
    switch ($opt) {
      { $_ -in @("--help", "-h") } {
        Show-InstallLaunchpadUsage
        return
      }
      "--skip-dock" { $pinTaskbar = $false; continue }
      "--skip-taskbar" { $pinTaskbar = $false; continue }
      default {
        Write-Fail ("doctor install-launchpad nezná argument: {0}" -f $opt)
        Write-Hint "spusť 'doctor install-launchpad --help'"
        if (-not $NoSummary) { _Write-Summary -label "Install Launchpad" }
        return
      }
    }
  }

  Write-Header "Launchpad GEN2 install"

  if (-not (Test-WindowsHost)) {
    Write-Host "  [skip] Windows Launchpad shortcut install běží jen na Windows"
    return
  }

  Add-DefaultToolPaths
  Require-Cmd bun

  $launchpadDir = Join-Path $rootDir "launchpad\app\v1"
  if (-not (Test-Path $launchpadDir)) {
    Write-Fail ("Launchpad runtime chybí: {0}" -f $launchpadDir)
    Write-Hint "ověř checkout launchpad/ v super-repu"
    if (-not $NoSummary) { _Write-Summary -label "Install Launchpad" }
    return
  }

  $launcherPath = New-LaunchpadWindowsLauncher
  Write-Ok ("launcher vytvořen: {0}" -f $launcherPath)

  $powerShellPath = Get-WindowsPowerShellPath
  $iconPath = New-LaunchpadWindowsIcon
  if ($iconPath) {
    Write-Ok ("ikona vytvořena: {0}" -f $iconPath)
  }

  $launcherExePath = New-LaunchpadWindowsExecutable -LauncherPath $launcherPath -IconPath $iconPath
  if ($launcherExePath) {
    Write-Ok ("exe launcher vytvořen: {0}" -f $launcherExePath)
    $shortcutTarget = $launcherExePath
    $shortcutArgs = ""
    $iconLocation = if ($iconPath) { "{0},0" -f $iconPath } else { "{0},0" -f $launcherExePath }
  } else {
    $shortcutTarget = $powerShellPath
    $shortcutArgs = ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $launcherPath)
    $iconLocation = if ($iconPath) { "{0},0" -f $iconPath } else { "{0},0" -f $powerShellPath }
  }

  $startMenuDir = Join-Path $env:APPDATA ("Microsoft\Windows\Start Menu\Programs\{0}" -f (Get-LaunchpadSafeCompanyName))
  $startMenuShortcut = Join-Path $startMenuDir ("{0}.lnk" -f (Get-LaunchpadSafeAppName))
  New-WindowsShortcut -ShortcutPath $startMenuShortcut -TargetPath $shortcutTarget -Arguments $shortcutArgs -WorkingDirectory $launchpadDir -IconLocation $iconLocation
  Write-Ok ("Start Menu zástupce vytvořen: {0}" -f $startMenuShortcut)

  if ($pinTaskbar) {
    Add-LaunchpadShortcutToTaskbar -ShortcutPath $startMenuShortcut
  } else {
    Write-Host "  [skip] taskbar update (--skip-taskbar/--skip-dock)"
  }

  if (-not $NoSummary) { _Write-Summary -label "Install Launchpad" }
}

# --- Subcommand: init ---

function Invoke-Init {
  param([string[]]$opts)

  $installDeps = $true
  $installLaunchpad = $true
  $pinLaunchpadTaskbar = $true
  $runCheck = $true

  foreach ($opt in $opts) {
    switch ($opt) {
      { $_ -in @("--help", "-h") } {
        Show-InitUsage
        return
      }
      "--skip-deps" { $installDeps = $false; continue }
      "--skip-launchpad-install" { $installLaunchpad = $false; continue }
      "--skip-dock" { $pinLaunchpadTaskbar = $false; continue }
      "--skip-taskbar" { $pinLaunchpadTaskbar = $false; continue }
      "--check" { $runCheck = $true; continue }
      "--no-check" { $runCheck = $false; continue }
      default {
        Write-Fail ("doctor init nezná argument: {0}" -f $opt)
        Write-Hint "spusť 'doctor init --help'"
        _Write-Summary -label "Init"
        return
      }
    }
  }

  Write-Header "Nested repo init"
  foreach ($path in Get-ManifestSubmodulePaths) {
    $url = Get-ManifestModuleUrl $path
    $branch = Get-ManifestModuleBranch $path
    $modulePath = Join-Path $rootDir ($path -replace '/', '\')

    if (-not $url) {
      Write-Host ("  [planned] {0}" -f $path)
      continue
    }

    if (Test-Path (Join-Path $modulePath ".git")) {
      Write-Ok ("{0} available" -f $path)
      continue
    }

    if (Test-Path $modulePath) {
      $entries = @(Get-ChildItem -Force $modulePath -ErrorAction SilentlyContinue)
      if ($entries.Count -gt 0) {
        Write-Warn ("{0} existuje, ale není Git repo — nepřepisuji" -f $path)
        continue
      }
    } else {
      $parent = Split-Path -Parent $modulePath
      if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent *> $null
      }
    }

    $rc = Invoke-NativeQuiet {
      git clone --branch $branch $url $modulePath
    }
    if ($rc -eq 0) {
      Write-Ok ("{0} cloned ({1})" -f $path, $branch)
    } else {
      $rcFallback = Invoke-NativeQuiet {
        git clone $url $modulePath
      }
      if ($rcFallback -eq 0) {
        Write-Warn ("{0} cloned bez explicitní branche {1}" -f $path, $branch)
      } else {
        Write-Warn ("{0} missing_access_or_not_ready" -f $path)
      }
    }
  }

  if ($installDeps) {
    Invoke-InstallDeps -opts @() -NoSummary
    if ($script:failCount -gt 0) {
      _Write-Summary -label "Init"
      return
    }
  } else {
    Write-Host "  [skip] dependency install (--skip-deps)"
  }

  if ($installLaunchpad) {
    $installLaunchpadOpts = @()
    if (-not $pinLaunchpadTaskbar) {
      $installLaunchpadOpts += "--skip-taskbar"
    }
    Invoke-InstallLaunchpad -opts $installLaunchpadOpts -NoSummary
    if ($script:failCount -gt 0) {
      _Write-Summary -label "Init"
      return
    }
  } else {
    Write-Host "  [skip] Launchpad install (--skip-launchpad-install)"
  }

  if ($runCheck) {
    Invoke-Check -opts @("--quick")
  } else {
    _Write-Summary -label "Init"
  }
}

# --- Subcommand: sync ---

function Invoke-Sync {
  param([string[]]$opts)
  if ($opts -contains "--help" -or $opts -contains "-h") {
    Show-SyncUsage
    return
  }

  foreach ($opt in $opts) {
    if ($opt -ne "--rebase") {
      Write-Fail ("doctor sync nezná argument: {0}" -f $opt)
      Write-Hint "spusť 'doctor sync --help'"
      return
    }
  }

  $rebase = $opts -contains "--rebase"

  Write-Header "Super-repo pull"
  $dirty = git -C $rootDir status --porcelain 2>$null
  if ($dirty) {
    Write-Warn "super-repo je dirty — přeskakuji pull"
    Write-Hint "commit/stash lokální změny a spusť doctor sync znovu"
  } else {
    if ($rebase) {
      git -C $rootDir pull --rebase origin main
      if ($LASTEXITCODE -eq 0) { Write-Ok "super-repo pull --rebase" } else { Write-Fail "super-repo pull --rebase selhal"; return }
    } else {
      git -C $rootDir pull --ff-only origin main
      if ($LASTEXITCODE -eq 0) { Write-Ok "super-repo pull --ff-only" }
      else { Write-Fail "super-repo pull --ff-only selhal (možná diverged)"; Write-Hint "zkus 'doctor sync --rebase'"; return }
    }
  }

  Write-Header "Nested repo sync"
  foreach ($path in Get-GitmodulePaths) {
    $url = Get-ManifestModuleUrl $path
    $branch = Get-ManifestModuleBranch $path
    $modulePath = Join-Path $rootDir ($path -replace '/', '\')
    $state = Get-ModuleState $path

    if ($state -eq "missing_access") {
      $parent = Split-Path -Parent $modulePath
      if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent *> $null
      }
      $rc = Invoke-NativeQuiet {
        git clone --branch $branch $url $modulePath
      }
      if ($rc -eq 0) {
        Write-Ok ("{0} cloned ({1})" -f $path, $branch)
      } else {
        Write-Warn ("{0} missing_access_or_not_ready" -f $path)
      }
      continue
    }

    if ($state -ne "available") {
      Write-Host ("  [skip] {0} (state: {1})" -f $path, $state)
      continue
    }

    if ((Get-SubmoduleDirty $path) -eq "dirty") {
      Write-Warn ("{0} — dirty, skip" -f $path)
      continue
    }

    $currentBranch = Get-SubmoduleBranch $path
    if ($currentBranch -ne $branch -and $currentBranch -ne "HEAD") {
      git -C $modulePath checkout $branch 2>&1 | Out-Null
    } elseif ($currentBranch -eq "HEAD") {
      git -C $modulePath checkout -B $branch 2>&1 | Out-Null
    }

    git -C $modulePath pull --ff-only origin $branch 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Ok ("{0} synced" -f $path)
    } else {
      Write-Warn ("{0} nested repo pull selhal" -f $path)
      Write-Hint "zkontroluj access, lokální branche a případnou divergenci"
    }
  }

  _Write-SyncSummary
}

# --- Subcommand: push ---

function Invoke-Push {
  param([string]$message)
  if ($message -eq "--help" -or $message -eq "-h") {
    Show-PushUsage
    return
  }

  $firebaseProductionSynced = $false
  if ($message -match '(^|\s)--firebase-production-synced(\s|$)') {
    $firebaseProductionSynced = $true
    $message = (($message -replace '(^|\s)--firebase-production-synced(\s|$)', ' ') -replace '\s+', ' ').Trim()
  }

  if (-not $message) {
    Write-Host "Musíš dodat commit message." -ForegroundColor Red
    Write-Host 'Usage: doctor push "<message>"' -ForegroundColor Red
    exit 2
  }

  Write-Header "Preflight"
  Write-Host "  Spouštím rychlý check..."
  # Invoke-Check's exit is fatal; do a simpler inline preflight instead.
  if (-not (Test-Path (Join-Path $rootDir ".git"))) {
    Write-Fail "není git repo — abort"; return
  }
  Write-Ok "preflight OK"

  if (-not (Test-CommitMessageQuality $message)) {
    return
  }

  if ((Test-FirebaseMirrorDirty) -and (-not $firebaseProductionSynced)) {
    Write-Header "Firebase mirror production sync"
    Write-Fail "modules/firebase/mirror je dirty, ale chybí produkční sync ack"
    Write-Hint "použij firebase-mirror-production-sync a cílený dry-run/write/ověření po dokumentech"
    Write-Hint "pak spusť doctor push s --firebase-production-synced, nebo uživateli explicitně nahlas odklad produkčního propsání"
    return
  }

  Write-Header "Commit+push dirty nested repo modulů"
  $anyCommitted = $false
  foreach ($path in Get-GitmodulePaths) {
    if ((Get-SubmoduleDirty $path) -ne "dirty") { continue }
    if ($path -in @("modules/monorepo", "modules/firmware")) {
      Write-Warn ("{0} je dirty, ale má task-driven workflow — přeskakuji doctor push" -f $path)
      Write-Hint "použij monorepo-fix skill nebo firmware vlastní flow"
      continue
    }

      Write-Host ("  > {0}" -f $path)
    $moduleCommitMsg = Add-CommitSubjectSuffix $message (" ({0})" -f $path)
    Push-Location (Join-Path $rootDir $path)
    try {
      git add -A 2>&1 | Out-Null
      git commit -m $moduleCommitMsg 2>&1 | Out-Null
      if ($LASTEXITCODE -ne 0) { Write-Fail ("commit v {0} selhal" -f $path); return }
      git push origin main 2>&1 | Out-Null
      if ($LASTEXITCODE -ne 0) {
        Write-Warn ("{0}: push selhal, zkouším pull --rebase" -f $path)
        git pull --rebase origin main 2>&1 | Out-Null
        git push origin main 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
          Write-Ok ("{0}: pull --rebase + retry push úspěšný" -f $path)
        } else {
          Write-Fail ("{0}: push stále selhává, manuální intervence" -f $path); return
        }
      }
      $anyCommitted = $true
      Write-Ok ("{0} committed a pushnuto" -f $path)
    } finally {
      Pop-Location
    }
  }

  if (-not $anyCommitted) {
    Write-Host "  [info] žádný dirty nested repo modul — přeskakuji module commit"
  }

  Write-Header "Super-repo commit"
  $commitMsg = $message

  $dirty = git -C $rootDir status --porcelain 2>$null
  if ($dirty) {
    git -C $rootDir add -A 2>&1 | Out-Null
    git -C $rootDir commit -m $commitMsg 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Fail "commit super-repa selhal"; return }
    Write-Ok "super-repo commit"

    git -C $rootDir push origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Ok "super-repo push"
    } else {
      Write-Warn "super-repo push selhal (možná diverged)"
      Write-Hint "nebo spusť 'git pull --rebase origin main ; git push' ručně"
      return
    }
  } else {
    Write-Host "  [info] super-repo je clean — žádný commit"
  }

  _Write-PushSummary
}

# --- Dispatch ---

Require-Cmd git
Add-DefaultToolPaths

$subcmd = if ($args.Length -gt 0) { $args[0] } else { "status" }
$rest = @()
if ($args.Length -gt 1) { $rest = $args[1..($args.Length - 1)] }

if ($subcmd -eq "--help" -or $subcmd -eq "-h") {
  Show-Usage
  exit 0
}

switch ($subcmd) {
  "status"           { Invoke-Status }
  "init"             { Invoke-Init -opts $rest }
  "install-deps"     { Invoke-InstallDeps -opts $rest }
  "install-launchpad" { Invoke-InstallLaunchpad -opts $rest }
  "check"            { Invoke-Check -opts $rest }
  "check-my-context" { Invoke-CheckMyContext }
  "workspace-tasks"  {
    if ($rest -contains "--help" -or $rest -contains "-h") {
      Show-WorkspaceTasksUsage
    } elseif ($rest.Length -gt 0) {
      Write-Host ("Unknown workspace-tasks option: {0}" -f $rest[0]) -ForegroundColor Red
      Show-WorkspaceTasksUsage
      exit 2
    } else {
      Invoke-WorkspaceTasks
    }
  }
  "sync"             { Invoke-Sync -opts $rest }
  "push"             { Invoke-Push -message ($rest -join " ") }
  default {
    Write-Host ("Unknown subcommand: {0}" -f $subcmd) -ForegroundColor Red
    Show-Usage
    exit 2
  }
}
