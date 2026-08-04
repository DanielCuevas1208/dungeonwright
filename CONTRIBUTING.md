# Contributing

Thank you for helping with Dungeonwright.
This guide explains how to set up, test, and submit changes.

## Setup

1. Install Godot 4.6 or newer.
2. Clone this repository.
3. Run `tools/install_gut.ps1` on Windows.
4. Run `tools/install_gut.sh` on Linux or macOS.

## Run the tests

Run `tools/run_tests.ps1` on Windows.
Run `tools/run_tests.sh` on Linux or macOS.
Set `GODOT_BIN` when Godot is not on PATH.
The suite runs headless and must pass.

Run the smoke test with `tools/smoke.gd`.
The smoke test loads the game and spawns a fixed-seed run.

## Code style

Follow the style of the existing scripts.
Use tabs for indentation.
Use `class_name` for shared types.
Keep pure data in `RefCounted` classes.
Keep scene logic in nodes.
Write a short comment above each public function.

## Tests

Add a deterministic test for new behaviour.
Unit tests cover pure data and math.
Integration tests cover scene flow.
Run the full suite before you open a pull request.

## Documentation

Update the README when user-facing behaviour changes.
Update `docs/architecture.md` when the design changes.
Add a changelog entry for the next release.
Write short, active sentences in public docs.
Do not use emojis in public docs.

## Submitting changes

Open a pull request against `main`.
Describe what changed and why.
Make sure every test passes on CI.
Do not commit build output or the Godot cache.
