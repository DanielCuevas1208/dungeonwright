# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Multi-floor runs with a floor counter.
- Reaching the exit on a lower floor descends.
- Every floor uses a deterministic child seed of the run seed.
- A stairs tile marks the exit of a lower floor.
- Monster pressure scales with each floor.
- A floor transition overlay between descents.
- Floor and run-seed metadata on generated dungeons.
- Unit and integration tests for the descent system.

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
