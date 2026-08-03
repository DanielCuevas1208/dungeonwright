# Roadmap

This roadmap tracks the planned releases.
It shows what is done and what remains.

## Released

### 0.1.0 - Foundations

- Seed-driven dungeon generation with three biomes.
- Rooms, corridors, locked doors, and keys.
- Monsters, melee combat, and drop tables.
- Deterministic replay from a seed string.
- Procedural tile art and a minimap.
- A headless test suite and a smoke test.

### 0.2.0 - Gamepad support

- Gamepad bindings for every action.
- Analog stick movement with a deadzone.
- Normalised diagonal movement speed.
- Control hints for the active device.

### 0.3.0 - Multi-floor descent

- Five floors per run with a floor counter.
- Reaching the exit on a lower floor descends.
- Per-floor monster scaling.
- Deterministic floor seeds from the run seed.

## Next up

### Ranged combat

- Ranged monsters and projectiles.

### Audio

- Sound and music.

### Content

- More biomes and items.

## Scope notes

- Every feature must keep generation deterministic.
- The exit must stay reachable on every floor.
- New systems need unit or integration tests.
