# Roadmap

This document tracks the direction of Dungeonwright.
Completed items are marked done.
Open items show the next planned work.

## Done

- Seed-driven dungeon generation. (0.1.0)
- Rooms, corridors, locked doors, and keys. (0.1.0)
- Three biomes with different generation rules. (0.1.0)
- Monsters, melee combat, and drop tables. (0.1.0)
- Deterministic replay from a seed string. (0.1.0)
- Full gamepad support for every action. (0.2.0)
- Multi-floor descent with a floor counter. (0.3.0)
- Depth scaling for monsters and spawn pressure. (0.3.0)

## Next up

- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.
- A bestiary or monster log.
- More floor variety in the run plan.
- An export build for desktop platforms.

## Principles

Every planned feature must keep the run deterministic.
A seed must always replay the same run.
Every generated floor must stay solvable.
New behaviour should ship with tests that run headless.
