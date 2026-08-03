# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Multi-floor runs with a depth counter.
- Three floors per run, each a fresh dungeon.
- A fresh biome on every floor.
- Deterministic per-floor seeds from the run seed.
- Keys reset when the hero descends.
- A descent flash that masks the switch between floors.
- Floor totals in the HUD and the run summary.
- Unit tests for the run plan.
- Integration tests for the descent flow.
- Smoke test coverage for the descent to the second floor.

Changed

- The hero now wins after clearing the final floor.
- The hero keeps health and loot between floors.

Fixed

- Repeated hero setup no longer stacks sprites and lights.

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
