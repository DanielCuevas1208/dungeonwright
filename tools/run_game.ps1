param(
    [string]$GodotBin = ""
)
## Launches Dungeonwright in the editor's native window.
$ErrorActionPreference = "Stop"

$tools = $PSScriptRoot
$root = Split-Path -Parent $tools

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
    & $godot --headless --import
    Write-Host "Launching Dungeonwright..."
    & $godot --path .
} finally {
    Pop-Location
}
