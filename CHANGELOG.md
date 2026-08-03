# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Multi-floor descent across four generated floors.
- A floor counter in the HUD and the run summary.
- Stairs tiles that lead from one floor to the next.
- A run plan that derives a deterministic seed for every floor.
- Biomes that cycle in a fixed order across floors.
- Deeper floors with more monsters and tougher stats.
- A small heal on descent between floors.
- Static checks for CI that compile every script and verify registries.
- Tests for the run plan, floor seeds, stairs, and monster scaling.

## [0.2.0] - 2026-08-03

Added

- Full gamepad support for every action.
- Analog stick movement with a deadzone.
- Normalised diagonal movement speed.
- D-pad and stick bindings for all movement.
- Gamepad bindings for attack, pause, and new run.
- Control hints that match the active device.
- Unit tests for the input bindings and helpers.

## [0.1.0] - 2026-08-03

Added

- Seed-driven dungeon generation with three biomes.
- Rooms, corridors, locked doors, and keys.
- Monsters, melee combat, and drop tables.
- Deterministic replay from a seed string.
- Procedural tile art and a minimap.
- A headless test suite and a smoke test.
