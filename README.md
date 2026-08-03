# Dungeonwright

```
####.D.############
##.........####..###
#######.#####.#..#E#
##...##......##.#..#
##.D.###.####.#####.
##......##.....#...#
##########.D..######
```

A seeded dungeon crawler built with Godot and GDScript.
Every run descends four floors.
Each floor builds a new map you can explore and finish.

## What it is

Dungeonwright builds a dungeon on every run.
You explore rooms and corridors.
You find keys, open locked doors, and reach the exit.
The same seed always builds the same dungeon.

## Features

- Multi-floor descent with a floor counter.
- A new map for every floor, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## This release

This release adds multi-floor descent.
A run spans four floors.
Each floor uses a biome from a fixed cycle.
Every floor gets its own seed, derived from the run seed.
Deeper floors add more monsters and tougher stats.
The HUD shows the floor and the exit depth.
Stairs lead down to the next floor.
The bottom floor holds the true exit.
Keys reset on descent.
The hero keeps health, coins, and shards.

## Requirements

- Godot 4.6 or newer.

## Quick start

1. Install Godot 4.6 from the official site.
2. Clone this repository.
3. Set `GODOT_BIN` to the Godot executable.
4. Run `tools/run_game.ps1` on Windows.
5. Run `tools/run_game.sh` on Linux or macOS.

The scripts find Godot on PATH automatically.
On Windows they also search common install locations.

Type a seed in the menu to replay a run.
Leave the field empty for a random seed.

## Controls

Move with WASD or the arrow keys.
Attack with Space, J, or a mouse click.
Press N for a new run.
Press M to toggle the minimap.
Press Escape to pause.

A gamepad works too.
Move with the left stick or the d-pad.
Attack with A or the right shoulder button.
Press Y for a new run.
Press Select to toggle the minimap.
Press Start to pause.

## Run the tests

Run `tools/run_tests.ps1` on Windows.
Run `tools/run_tests.sh` on Linux or macOS.

The script installs GUT, imports the project, and runs the suite.
Tests run headless, so no window opens.

## How it works

The generator has a fixed pipeline.
It places rooms, connects them with corridors, and carves the map.
It picks the farthest room as the exit.
It places doors on corridors and puts each key on the safe side.
A solver then proves the dungeon can be completed.

A run plan decides the floors.
Each floor gets a seed and a biome.
The floor index scales the monster pressure.
The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/core` holds the run plan and run state.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Sample output

A headless run prints the smoke test result.

```
[smoke] loading main scene
[smoke] scene added
[smoke] starting run with seed 12345
Smoke test passed: seed 12345 spawned a solvable multi-floor run.
```

## Design guarantees

A seed always produces the same run.
Every floor is solvable.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.

## Evaluation evidence

The suite has 94 tests.
It covers generation, biomes, combat, drops, pathfinding, input,
and the run plan.
All 94 tests pass in a headless run.
A smoke test loads the game, spawns a fixed-seed run, and descends.
A static check compiles every script and verifies the registries.
CI runs the suite, the smoke test, and the static check.

## Roadmap

See `docs/roadmap.md` for the full plan.
Done: seed-driven maps, three biomes, combat and drops,
gamepad support, and multi-floor descent.
Next up: ranged monsters, sound, and more biomes.

## Limitations

The run has four fixed floors.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
