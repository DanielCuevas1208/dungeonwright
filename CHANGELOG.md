# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Multi-floor runs that descend into a new dungeon per floor.
- A deterministic floor seed chain from a single run seed.
- A floor counter in the HUD and on the result screen.
- A floor-cleared transition overlay.
- The hero keeps coins and shards between floors.
- The exit only ends the run on the final floor.
- Unit and integration tests for the descent chain.
- A smoke test that clears every floor of a run.

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
