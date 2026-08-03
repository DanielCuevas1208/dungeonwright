# Architecture

This document explains the design of Dungeonwright.
It covers the generation pipeline, the combat model, the multi-floor
run, and the scene flow.

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

The optional floor number scales monster pressure.
Deeper floors hold more monsters.
Floor zero is neutral, so single-floor maps stay unchanged.

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

## Multi-floor runs

A run is a descent through three floors.
The `RunProgression` module holds the run-level rules.

Each floor gets its own map and biome.
The floor seed derives from the run seed and the floor number.
A fixed hash makes the sequence repeatable.

Every floor uses a floor-seeded biome choice.
Reaching the exit of a floor opens the stairwell prompt.
The hero chooses to descend or to stay.
On the final floor the exit is the goal and ends the run.

Progress carries across floors.
The hero keeps coins, health, and shards.
Keys reset because each floor has its own doors.
Descending restores a fixed amount of health.

Monsters scale with the floor.
Hit points and damage grow each floor.
The generator places more monsters on deeper floors.

## Combat model

The player and each monster carry a `CombatStats` block.
Pure functions in `scripts/combat` compute damage.
Attack range and facing arcs use tile math, not physics.

The player attacks in a facing arc.
Monsters chase, stalk, or hold ground according to their spec.
Each monster rolls loot from a weighted `DropTable`.
Coins drop often, shards sometimes, potions rarely.

## Scene flow

The `Main` scene owns the game loop.
It generates a map and spawns the world.
The hero, monsters, and pickups are plain nodes.
The hero moves tile to tile with smooth interpolation.
Monsters follow short flood-fill paths.

`Main` builds one floor at a time.
It calls `RunProgression` for the biome and the floor seed.
Descending keeps the hero node and rebuilds the world.
The world renders from a tile map.
A `TileArt` class draws every sprite from pixel patterns.
The biome palette recolors the tiles at run time.

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
Unit tests cover the RNG, generator, biomes, combat, drops, and the
run progression rules.
Integration tests run many seeds across all biomes.
Every generated dungeon must be solvable.
Multi-floor tests replay whole runs and check every floor stays solvable.

Run the suite with `tools/run_tests`.
CI runs the same commands on every push.
