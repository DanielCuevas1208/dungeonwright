# Changelog

All notable changes are listed here. The format follows Keep a Changelog.
Versions follow Semantic Versioning.

## [Unreleased]

### Added

- Multi-floor runs. The hero descends through several floors after
  clearing each one. Each biome defines its own floor count.
- A deterministic seed chain. One run seed replays every floor.
- A floor counter in the HUD.
- A floor summary in the victory and defeat overlay.
- A floor transition overlay.
- A unit and integration suite for the descent system.

### Changed

- Reaching a floor exit descends instead of ending the run.
- The final floor of a run awards victory.
- Coins and shards persist between floors. Keys reset each floor.
- CI now uses a current checkout action and cancels superseded runs.

### Fixed

- The hero visuals are created once, so descending keeps the sprite.
