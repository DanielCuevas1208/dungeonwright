param(
    [string]$GodotBin = ""
)
## Imports the project and runs the GUT test suite headless.
$ErrorActionPreference = "Stop"

$tools = $PSScriptRoot
$root = Split-Path -Parent $tools

if (-not (Test-Path (Join-Path $root "addons\gut"))) {
    & (Join-Path $tools "install_gut.ps1")
}

$godot = $GodotBin
if (-not $godot) {
    $godot = (Get-Command godot -ErrorAction SilentlyContinue).Source
}
if (-not $godot) {
    $candidates = Get-ChildItem `
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine*\Godot_v4*_win64_console.exe" `
        -ErrorAction SilentlyContinue
    if ($candidates) {
        $godot = $candidates[0].FullName
    }
}
if (-not $godot) {
    throw "Godot binary not found. Pass -GodotBin <path> or add Godot to PATH."
}

Push-Location $root
try {
    Write-Host "Importing project resources..."
    & $godot --headless --log-file godot-test.log --import
    if ($LASTEXITCODE -ne 0) {
        throw "Godot import failed with exit code $LASTEXITCODE"
    }
    Write-Host "Running GUT tests..."
    & $godot --headless --log-file godot-test.log --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
    if ($LASTEXITCODE -ne 0) {
        throw "GUT tests failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}
Write-Host "All tests passed."
