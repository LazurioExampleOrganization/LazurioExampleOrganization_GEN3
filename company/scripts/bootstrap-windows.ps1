Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Test-WindowsHost {
  return ($env:OS -eq "Windows_NT" -or [Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)
}

if (-not (Test-WindowsHost)) {
  Write-Error "This bootstrap script is intended for Windows."
}

$doctorPath = Join-Path $scriptDir "doctor.ps1"
if (-not (Test-Path $doctorPath)) {
  Write-Error "Missing doctor.ps1 at $doctorPath"
}

Write-Host "AgentMint GEN2 bootstrap for Windows"
Write-Host "Delegating workspace initialization to doctor init."
Write-Host ""

& $doctorPath init @args
exit $LASTEXITCODE
