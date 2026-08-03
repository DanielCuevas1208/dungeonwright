# Changelog

All notable changes are listed here. The format follows Keep a Changelog.
Versions follow Semantic Versioning.

## [Unreleased]

### Added

- A fourth biome: the Sunken Ruins.
  The biome uses wide winding corridors and a deep teal palette.
- A new monster: the Riptide.
  The Riptide is a fast stalker that drops upgrade items.
- Two permanent upgrade items.
  A whetstone raises attack damage by 2.
  A relic raises max health by 10 and heals part of the gap.
- An item registry with ids, names, categories, and upgrade math.
- A HUD readout that shows collected stat bonuses.
- A unit and integration suite for items and the new biome.

### Changed

- Monster drop tables can now carry optional extra entries.
- The hero tracks permanent damage and max-health bonuses per run.
- The headless smoke test also verifies the Sunken Ruins
  and the upgrade effects.

### Fixed

- None.

## [1.0.0] - 2026-08-03

### Added

- Seeded dungeon generation with a guaranteed reachable exit.
- Three biomes with different generation rules.
- Rooms, corridors, locked doors, keys, and monsters.
- Procedural pixel art generated from code.
- A minimap, a health bar, and run summary overlays.
- A GUT test suite and headless CI pipeline.
