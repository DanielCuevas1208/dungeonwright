# Changelog

All notable changes are listed here.
The format follows Keep a Changelog.
Versions follow Semantic Versioning.

## [Unreleased]

### Added

- Procedural sound effects generated from code.
- A looping ambient music bed for every biome.
- A deterministic PCM synthesis layer.
- An audio hub that pools effect players and caches streams.
- A mute toggle that stops all output and shows a HUD label.
- Unit tests for synthesis, effects, and music.
- Integration tests for the audio hub.

### Changed

- The game controller plays effects for attacks, drops, doors,
  victory, defeat, and the start of a run.
- The smoke test now verifies the audio system.
- CI cancels superseded runs and pins checkout to a known version.
- Dependabot now watches GitHub Actions for weekly updates.

## [0.1.0] - 2026-08-03

### Added

- Seeded dungeon generation with guaranteed solvability.
- Rooms, corridors, locked doors, keys, and a reachable exit.
- Three biomes with distinct generation rules and palettes.
- Monsters with simple combat and weighted loot tables.
- Procedural pixel art generated from pixel patterns.
- A minimap, a health bar, and run summary overlays.
- A headless test suite and CI workflow.
