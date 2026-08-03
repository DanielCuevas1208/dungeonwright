param(
    [switch]$Force
)
## Installs the pinned GUT version into addons/gut.
## Downloads and extracts in the system temp folder so the project
## never contains duplicate GUT files.
$ErrorActionPreference = "Stop"

$tools = $PSScriptRoot
$root = Split-Path -Parent $tools
$manifest = Get-Content -Raw (Join-Path $tools "gut.version.json") | ConvertFrom-Json
$target = Join-Path $root "addons\gut"
$work = Join-Path $env:TEMP "dungeonwright-gut-install"
$archive = Join-Path $work ("Gut-" + $manifest.version + ".zip")
$extract = Join-Path $work ("gut_extract_" + $manifest.version)

if ((Test-Path $target) -and (-not $Force)) {
    Write-Host "GUT is already installed at $target. Use -Force to reinstall."
    exit 0
}

New-Item -ItemType Directory -Force -Path $work | Out-Null
if (-not (Test-Path $archive)) {
    Write-Host "Downloading GUT $($manifest.version)..."
    Invoke-WebRequest -Uri $manifest.archive_url -OutFile $archive
}
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
if ($hash -ne $manifest.sha256) {
    throw "GUT archive checksum mismatch. Expected $($manifest.sha256), got $hash."
}

if (Test-Path $extract) {
    Remove-Item -Recurse -Force -LiteralPath $extract
}
Expand-Archive -LiteralPath $archive -DestinationPath $extract -Force
$source = Join-Path $extract ($manifest.addon_path_in_archive -replace "/", "\")
if (-not (Test-Path $source)) {
    throw "GUT addon folder not found inside the archive."
}
if (Test-Path $target) {
    Remove-Item -Recurse -Force -LiteralPath $target
}
Copy-Item -Recurse -Force -LiteralPath $source -Destination $target
Write-Host "Installed GUT $($manifest.version) to $target"
