# Install Olympus skills (Windows PowerShell).
#   All, global:   iex (irm https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.ps1)
#   With options:  irm https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.ps1 -OutFile install.ps1
#                  ./install.ps1 -Only titan-the-developer,atlas-the-planner
#                  ./install.ps1 -Project
param(
  [switch]$Project,
  [string]$Dest = "",
  [string[]]$Only = @()
)

$ErrorActionPreference = "Stop"
$Repo = "https://github.com/Alphred-OB/Olympus.git"

if (-not $Dest) {
  if ($Project) { $Dest = Join-Path (Get-Location) ".claude\skills" }
  else { $Dest = Join-Path $HOME ".claude\skills" }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "git is required"
  exit 1
}

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("olympus-" + [guid]::NewGuid())
git clone --depth 1 --quiet $Repo $Tmp

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
$count = 0
Get-ChildItem (Join-Path $Tmp "skills") -Directory | ForEach-Object {
  if ($Only.Count -gt 0 -and ($Only -notcontains $_.Name)) { return }
  $Target = Join-Path $Dest $_.Name
  if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
  Copy-Item -Recurse $_.FullName $Target
  Write-Host "Installed $($_.Name)"
  $count++
}

Remove-Item -Recurse -Force $Tmp
Write-Host "Done. $count skill(s) in $Dest"
