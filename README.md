# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run builds a fresh dungeon, and every dungeon can repeat from its seed.

```
####.D.############
##.........####..###
#######.#####.#..#E#
##...##......##.#..#
##.D.###.####.#####.
##......##.....#...#
##########.D..######
```

## What it is

Dungeonwright generates a connected dungeon on every run.
You explore rooms and corridors.
You find keys, open locked doors, and reach the exit.
A run now spans three floors.
Each floor is a new dungeon that gets harder as you descend.
The same seed always builds the same three-floor run.

## Features

- A new map for every floor, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- A three-floor descent with a floor counter.
- Three biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## This release

This release adds the multi-floor descent.
A run now covers three floors.
Reaching the exit of a floor opens a stairwell.
The hero descends, keeps coins and health, and continues.
Monsters grow stronger on each deeper floor.
The final floor holds the goal.

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

## Sample output

A seed like `A7KQ2M` produces one map per floor.
The map above shows a single floor.
The `D` marks a locked door.
The `E` marks the floor exit.
Deeper floors hold more monsters.

The test runner prints a summary when the suite finishes.

```
Tests                87
Passing Tests        87
Asserts            4193
---- All tests passed! ----
```

## Run the tests

Run `tools/run_tests.ps1` on Windows.
Run `tools/run_tests.sh` on Linux or macOS.

The script installs GUT, imports the project, and runs the suite.
Tests run headless, so no window opens.

## Install the test framework

GUT is a test addon for Godot.
The tool scripts can download and install it.
The version and checksum are pinned in `tools/gut.version.json`.
The tests run from the copy in `addons/gut`.

## How it works

The generator has a fixed pipeline.
It places rooms, connects them with corridors, and carves the map.
It picks the farthest room as the exit.
It places doors on corridors and puts each key on the safe side.
A solver then proves the dungeon can be completed.

A run is a descent through three floors.
`RunProgression` derives a seed and a biome for every floor.
The scene controller builds one floor at a time.
Progress carries over between floors.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/core` holds the run state and the descent rules.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same map.
A run always replays the same floor sequence.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.

## Evaluation evidence

The suite has 87 tests.
It covers generation, biomes, combat, drops, pathfinding, input, and
the descent rules.
All 87 tests pass in a headless run.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test also checks every action has a gamepad binding.
The smoke test verifies a descent keeps coins and resets keys.

## Roadmap

Done in this release:
- Multi-floor descent and a floor counter.

Done in earlier releases:
- Seeded generation, rooms, doors, and keys.
- Combat, monsters, and loot tables.
- Procedural art, a minimap, and run overlays.
- Full gamepad support.

Next up:
- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
A run has exactly three floors.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
