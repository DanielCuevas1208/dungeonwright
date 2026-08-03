#!/usr/bin/env bash
# Imports the project and runs the GUT test suite headless.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -d "addons/gut" ]; then
  bash tools/install_gut.sh
fi

GODOT="${GODOT_BIN:-godot}"

echo "Importing project resources..."
"$GODOT" --headless --import

echo "Running GUT tests..."
"$GODOT" --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit

echo "All tests passed."
