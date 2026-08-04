# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Ranged combat with projectiles.
- Three new ranged monsters across the biomes.
- Line-of-sight checks so monsters cannot shoot through walls.
- Kiting behaviour that keeps ranged monsters at a distance.
- Unit tests for aim, blocking, and line of sight.
- Integration tests for firing, impact, and wall stops.

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
