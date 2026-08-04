# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.3.0] - 2026-08-03

Added

- Multi-floor descent across three floors.
- A floor counter in the HUD.
- Difficulty scaling for monsters on deeper floors.
- A heal between floors that keeps hero health.
- Loot that carries across floors.
- Run rules with deterministic per-floor seeds.
- Integration tests for the descent flow.

Changed

- Reaching the exit now descends until the final floor.
- Run summaries show the floor reached.
- Coins reset at the start of a new run.

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
