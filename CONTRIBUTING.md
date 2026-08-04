# Contributing

Thank you for improving Dungeonwright.
This guide explains how to set up, change, and test the project.

## Development setup

1. Install Godot 4.6 from the official site.
2. Clone this repository.
3. Set `GODOT_BIN` to the Godot executable.
4. Install the pinned GUT addon with `tools/install_gut.sh` or `tools/install_gut.ps1`.

## Make a change

Keep the generation code pure data.
Add deterministic tests for every behaviour you change.
Run the test suite before you open a pull request.

## Run the checks

1. Run `tools/run_tests.sh` on Linux or macOS.
2. Run `tools/run_tests.ps1` on Windows.
3. Run `tools/smoke.gd` headless with Godot.

The suite must pass with a clean import.
Import must not leave untracked files behind.

## Code style

Use tabs for indentation in GDScript files.
Follow the existing naming and comment style.
Keep public documentation in plain English.
Use short sentences and no emojis.
