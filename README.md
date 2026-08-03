# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run builds a three-floor dungeon that you can explore and finish.

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
You find keys, open locked doors, and descend stairs.
A run spans three floors, and the same seed replays every floor.
The same seed always builds the same dungeon.

## Features

- A new three-floor dungeon for every run, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- Stairs down and a floor counter in the HUD.
- Three biomes with different generation rules.
- Deeper floors add more monsters and tougher hero stats.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## This release

This release adds multi-floor descent.
Reaching the exit on a floor brings you to the stairs.
The stairs carry you to the next, harder floor.
A floor counter shows your depth in the top-left panel.
The deepest floor holds the true exit, where the run ends in victory.

## Sample run

The generator prints a dungeon as text in the terminal.
Here is floor two of a run, seed `0093CI`.
`#` is a wall, `.` is a floor, `D` is a locked door, and `>` is the stairs down.

```
##############################################
##############################################
##############......##########################
##############......##########################
##############......##########################
##############......##########################
##############......##########################
##############......###########.......########
####........#######D###########.......########
####........#######.###########.......########
####........###.........#######...>...########
####........###.........#######.......########
####........###.........#######.......########
####........###.........##########.###########
########.######....S.......D..####.###########
########.######.........#####.####.........###
########.######.........##.......#.........###
########.######.........##.......#.........###
#####.........#.........##.......#.........###
#####.........#####.######........D........###
#####.........#####.######.......##........###
#####.........#........###.......##........###
#####.........#........###.......###.#########
#####.........#........###########.....#######
#########..............###########.....#######
###############........###########.....#######
###############........###########.....#######
###############........###########.....#######
##############################################
##############################################
```

Floor one starts at `S`, and every floor stays solvable.
Replaying the seed `0093CI` rebuilds the same three floors.

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

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

A run profile drives the whole descent.
It derives a fresh seed for each floor from the run seed.
It scales the biome rules so deeper floors get harder.
Reaching the exit on a shallow floor replaces it with stairs.

## Project layout

- `scripts/core` holds the run profile and shared run state.
- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same three floors.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Deeper floors always stay solvable.

## Evaluation evidence

The suite has 83 tests.
It covers generation, biomes, floors, combat, drops, pathfinding, and input.
All 83 tests pass in a headless run.
A smoke test loads the game and descends a fixed-seed run to the bottom.
The smoke test also checks every action has a gamepad binding.

## Roadmap

Done in this release:
- Multi-floor descent and a depth counter.

Next up:
- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
Each run is three floors deep.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
