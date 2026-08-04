# Architecture

This document explains the design of Dungeonwright.
It covers the generation pipeline, the combat model, and the scene flow.

## Generation pipeline

The generator lives in `scripts/dungeon`.
It reads a seed and a biome, and it returns a `DungeonResult`.
The result holds the map, rooms, corridors, and all placed features.

The pipeline runs in a fixed order.

1. Place rooms without overlaps.
2. Connect every room with a spanning tree of corridors.
3. Add optional shortcut corridors for loops.
4. Carve the biome corridor style into the map.
5. Choose the start and the farthest room as the exit.
6. Place doors and keys.
7. Scatter monsters in the rooms.

### Room placement

The generator draws random rectangles in the map bounds.
It rejects a room when it overlaps an existing room.
It repeats until it reaches the target room count.

### Connectivity

A Prim-like loop links every unconnected room to its nearest neighbor.
The result is a spanning tree, so the map is connected by construction.
Shortcuts add loops so the player has more than one path.

### Corridor styles

Each biome picks a carving style.

- Elbow: an L-shaped path with one bend.
- Winding: a path of short, jittered runs.
- Straight: a path that favors one axis at a time.

All carvers keep every carved cell orthogonally adjacent to the path.
This rule prevents floating single-cell islands.

### Doors and keys

Doors sit on tree corridors.
The generator chooses a walkable tile near the middle of a corridor.

Keys must be reachable before their door opens.
The generator simulates the run to enforce this rule.
It floods the map from the start with every door locked.
It places the current door key inside that reachable region.
Then it opens the door and repeats for the next door.

This method survives corridor crossings.
A door tile can block another corridor on the map.
The simulation still finds a valid opening order.

### Solvability

The `Solvability` class proves a dungeon can be finished.
It replays the flood with a real key and door model.
A locked door opens only after the player finds its key.
The generator runs this check on every map.
The test suite treats the check as a core property.

## Seeded randomness

All randomness uses `SeededRng`.
The class wraps the mulberry32 algorithm.
The output depends only on the seed, never on the platform.
Seeds display as six-character base-36 strings.

A run uses one run seed.
Each floor derives its dungeon seed from that run seed.
`RunRules.floor_seed` mixes the run seed with the floor number.
Floor one uses the run seed unchanged.

## Combat model

The player and each monster carry a `CombatStats` block.
Pure functions in `scripts/combat` compute damage.
Attack range and facing arcs use tile math, not physics.

The player attacks in a facing arc.
Monsters chase, stalk, or hold ground according to their spec.
Each monster rolls loot from a weighted `DropTable`.
Coins drop often, shards sometimes, potions rarely.

## Ranged combat

Archers fire projectiles at the hero.
The `Combat` class provides two helpers for ranged attacks.
`has_line_of_sight` checks every tile between two cells.
A wall or a locked door blocks the line.
`direction_toward` returns the eight-direction step toward a target.

A `Projectile` node carries the shot.
It holds a damage value, a speed, a direction, and a range.
The scene controller calls `tick` every frame.
A bolt moves one tile at a time toward its direction.
Walls, locked doors, and the map edge stop a bolt.
A bolt expires when its range runs out.
When a bolt reaches the hero's tile, it calls `take_damage`.

Archers aim at the hero's current tile.
Bolts take time to arrive, so the hero can dodge.
An archer holds its ground while it has line of sight.
Without line of sight, the archer closes the distance.
A melee monster never fires a bolt.

## Scene flow

The `Main` scene owns the game loop.
It generates a map and spawns the world.
The hero, monsters, and pickups are plain nodes.
The hero moves tile to tile with smooth interpolation.
Monsters follow short flood-fill paths.

The world renders from a tile map.
A `TileArt` class draws every sprite from pixel patterns.
The biome palette recolors the tiles at run time.

## Floor descent

A run spans three floors.
`RunRules` in `scripts/core` defines the run.
It holds the floor count, the difficulty curve, and the heal rate.

Each floor uses a derived seed.
Floor one uses the run seed unchanged.
Deeper floors mix the run seed with the floor number.
This keeps every run replayable from one seed.

The hero keeps health and loot between floors.
Keys reset, because each floor has its own doors.
The hero heals a fraction of missing health on descent.
Monsters use scaled stats on deeper floors.

The scene controller descends when the hero reaches the exit.
The run ends when the hero clears the final floor.
`MonsterSpec.scaled` copies a spec with stronger health and damage.
The generator and the rest of combat stay unchanged.

Ranged monsters share the same scene flow.
An archer emits `ranged_fired` when it shoots.
The controller spawns a `Projectile` in the world.
It refreshes the bolt's target tile to follow the hero.
A bolt that lands on the hero damages the hero.

## Input handling

A `Controls` class reads all movement input.
It combines the keyboard and the first connected gamepad.
It applies a deadzone so a resting stick stays still.
It caps diagonal speed at one.
The hero reads its movement from this class.

Every action has a keyboard and a gamepad binding.
The input map in `project.godot` holds both sets.
Menus ask `Controls` for the correct labels.
The hints update when a gamepad connects or disconnects.

## Testing

The suite runs headless with GUT.
Unit tests cover the RNG, generator, biomes, combat, drops, and run rules.
Unit tests also cover line of sight and projectile flight.
Integration tests run many seeds across all biomes.
Integration tests also drive the floor descent flow.
Integration tests verify archers fire and bolts damage the hero.
Every generated dungeon must be solvable.
Each floor must be a fresh solvable dungeon.

Run the suite with `tools/run_tests`.
CI runs the same commands on every push.
