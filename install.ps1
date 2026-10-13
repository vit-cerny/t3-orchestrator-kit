# T3 orchestrator kit - installer.
# Windows PowerShell 5.1 compatible, ASCII only.
#
# Project (default): write AGENTS.md into a project so T3 threads opened there orchestrate.
# Global:            append the same rules to ~/.config/opencode/AGENTS.md so every thread does.
#
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Scope Global
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Target C:\path\to\project
[CmdletBinding()]
param(
  [ValidateSet("Project", "Global")]
  [string]$Scope = "Project",
  [string]$Target = (Get-Location).Path,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root "AGENTS.md"
if (-not (Test-Path $source)) { throw "AGENTS.md not found next to install.ps1" }
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

if ($Scope -eq "Project") {
  $dest = Join-Path $Target "AGENTS.md"
  if (-not (Test-Path $Target)) { throw "Target does not exist: $Target" }
  if ($DryRun) { Write-Host "Would write $dest"; exit 0 }
  if (Test-Path $dest) {
    $backup = "$dest.bak.$stamp"
    Copy-Item -Path $dest -Destination $backup -Force
    Write-Host "Backup: $backup"
  }
  Copy-Item -Path $source -Destination $dest -Force
  Write-Host "Wrote $dest"
  Write-Host ""
  Write-Host "New T3 threads opened in that project now orchestrate. Threads already running keep"
  Write-Host "their loaded instructions; open a new thread to pick this up."
  exit 0
}

# Global scope: append one delimited block, idempotently.
$globalDir = Join-Path $env:USERPROFILE ".config\opencode"
$globalPath = Join-Path $globalDir "AGENTS.md"
$start = "<!-- t3-orchestrator-kit:start -->"
$end = "<!-- t3-orchestrator-kit:end -->"

if (-not (Test-Path $globalDir)) { New-Item -ItemType Directory -Force -Path $globalDir | Out-Null }
$existing = if (Test-Path $globalPath) { [System.IO.File]::ReadAllText($globalPath) } else { "" }

if ($existing.Contains($start)) {
  Write-Host "Global block already present in $globalPath; nothing to do."
  exit 0
}

$block = $start + "`n`n" + [System.IO.File]::ReadAllText($source) + "`n" + $end + "`n"
if ($DryRun) { Write-Host "Would append the block to $globalPath"; exit 0 }

if (Test-Path $globalPath) {
  $backup = "$globalPath.bak.$stamp"
  Copy-Item -Path $globalPath -Destination $backup -Force
  Write-Host "Backup: $backup"
}

[System.IO.File]::WriteAllText($globalPath, $existing + "`n" + $block)
Write-Host "Appended the orchestration block to $globalPath"
Write-Host ""
Write-Host "Remove it later by deleting everything from $start to $end."
