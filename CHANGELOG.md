# Changelog

All notable changes are listed here. The format follows Keep a Changelog.
Versions follow Semantic Versioning.

## [Unreleased]

### Added

- Ranged monsters that hold a firing range and attack on line of sight.
- Three projectile types, one per biome.
- A pure flight model for deterministic projectile movement.
- A projectile actor that renders flight and reports hits.
- Line-of-sight checks that treat walls and locked doors as solid.
- New ranged monster types: Bone Archer, Sporecaster, and Ember Hellion.
- Unit tests for projectiles, line of sight, and ranged decision math.
- Integration tests that cover ranged spawning in every biome.

### Changed

- The dungeon generator now places ranged monsters in every biome.
- Monsters can fire without entering melee range.
- CI cancels superseded runs and pins checkout to a known version.
- Dependabot now watches GitHub Actions for weekly updates.

## [0.1.0] - 2026-08-03

### Added

- Seeded dungeon generation with guaranteed solvability.
- Rooms, corridors, locked doors, keys, and a reachable exit.
- Three biomes with distinct generation rules and palettes.
- Melee monsters with weighted loot tables.
- Procedural pixel art generated from pixel patterns.
- A minimap, a health bar, and run summary overlays.
- A headless test suite and CI workflow.
