# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run builds a new dungeon that you can explore and finish.

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
The same seed always builds the same dungeon.

## Features

- A new map for every run, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Multi-floor runs with a floor counter.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## First release

This release ships a playable demo.
The generator guarantees the exit is always reachable.
You can walk, fight, collect loot, and finish a run.
You can replay any run from its seed.

## This release

This release adds multi-floor descent.
A run now spans several floors, set by the biome.
The crypt runs two floors.
The drowned forest runs three floors.
The ember stronghold runs four floors.

The exit of a lower floor is a staircase.
Walk onto it to descend to the next floor.
Each floor is a fresh dungeon from a child seed.
A floor counter and a transition card show your depth.

Loot and health carry between floors.
Keys reset, because every floor has its own doors.
Monster pressure rises on every deeper floor.
The run ends only when you clear the final floor.

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

A run starts from one seed.
Every floor uses a child seed derived from it.
The derivation is a fixed integer hash, so a run replays exactly.
The biome sets the number of floors and the monster curve.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/core` holds run state and the descent rules.
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

A seed always produces the same run.
Every floor of the run stays solvable.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.

## Evaluation evidence

The suite has 83 tests.
It covers generation, biomes, combat, drops, pathfinding, input,
and descent.
All 83 tests pass in a headless run.
A smoke test loads the game and clears every floor.
The smoke test also checks every action has a gamepad binding.

## Roadmap

See `docs/roadmap.md` for the full plan.

Done in this release:
- Multi-floor descent and a depth counter.

Done in earlier releases:
- Full gamepad support.
- A playable single-floor demo.

Next up:
- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
The biome sets the run length.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
