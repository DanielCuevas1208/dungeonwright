#!/usr/bin/env bash
# Runs the game locally. Set GODOT_BIN to point at the Godot executable.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
GODOT="${GODOT_BIN:-godot}"

echo "Importing project resources..."
"$GODOT" --headless --import

echo "Launching Dungeonwright..."
"$GODOT" --path .
