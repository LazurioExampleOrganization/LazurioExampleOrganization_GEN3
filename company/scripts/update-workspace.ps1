Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent (Split-Path -Parent $scriptDir)

Write-Host "AgentMint GEN2 workspace update"
Write-Host "Workspace root: $rootDir"
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "Missing dependency: git"
}

$rootStatus = git -C $rootDir status --porcelain
if ($rootStatus) {
  throw "Root workspace is dirty. Refusing to run update automatically."
}

git -C $rootDir pull --ff-only

$manifestPath = Join-Path $rootDir "company\scripts\modules.manifest.json"
if (-not (Test-Path $manifestPath)) {
  Write-Host "No modules manifest found. Nothing else to update."
  exit 0
}

# Update each active nested repo declared in modules.manifest.json.
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$modules = $manifest.module_slots | Where-Object {
  $_.PSObject.Properties.Name -contains "git" -and $_.git -and $_.git.url
}

foreach ($slot in $modules) {
  $module = $slot.path
  $url = $slot.git.url
  $branch = "main"
  if ($slot.git.PSObject.Properties.Name -contains "branch" -and $slot.git.branch) {
    $branch = $slot.git.branch
  }
  $modulePath = Join-Path $rootDir ($module -replace '/', '\')

  if (-not (Test-Path (Join-Path $modulePath ".git"))) {
    $parent = Split-Path -Parent $modulePath
    if (-not (Test-Path $parent)) {
      New-Item -ItemType Directory -Force -Path $parent *> $null
    }
    try {
      git clone --branch $branch $url $modulePath *> $null
      Write-Host "[cloned] $module"
    } catch {
      Write-Host "[skipped_unavailable_or_no_access] $module"
    }
    continue
  }

  $moduleStatus = git -C $modulePath status --porcelain 2>$null
  if ($moduleStatus) {
    Write-Host "[skipped_dirty] $module"
    continue
  }

  try {
    git -C $modulePath pull --ff-only origin $branch *> $null
    Write-Host "[updated] $module"
  } catch {
    Write-Host "[skipped_unavailable_or_no_access] $module"
  }
}
