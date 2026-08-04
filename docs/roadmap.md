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

- Runs span several floors with a floor counter.
- Reaching a lower floor exit descends.
- Deterministic child seeds for every floor.
- Monster pressure scales with each floor.
- A floor transition overlay between descents.

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
