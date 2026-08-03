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

Dungeonwright builds a connected dungeon on every run.
You explore rooms and corridors.
You find keys, open locked doors, and descend.
The same seed always builds the same dungeon.

## Features

- A new map for every run, driven by a seed.
- Multi-floor runs that end in victory or defeat.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.

## This release

This release adds multi-floor descent.
The hero clears a floor, then moves down to the next one.
Coins and shards carry over between floors.
The run ends when the hero dies or clears the final floor.
Each biome has its own number of floors.
One seed replays the whole run.

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
Walk into a locked door to open it with a key.
Reach the exit to descend to the next floor.
Press N for a new run.
Press M to toggle the minimap.
Press Escape to pause.

## Run the tests

Run `tools/run_tests.ps1` on Windows.
Run `tools/run_tests.sh` on Linux or macOS.

The script installs GUT, imports the project, and runs the suite.
Tests run headless, so no window opens.

## Install the test framework

GUT is a test addon for Godot.
The tool scripts download and install it.
The version and checksum are pinned in `tools/gut.version.json`.
The addon is not committed to the repository.

## How it works

The generator has a fixed pipeline.
It places rooms, connects them with corridors, and carves the map.
It picks the farthest room as the exit.
It places doors on corridors and puts each key on the safe side.
A solver then proves the dungeon can be completed.

A run owns one seed.
Each floor uses a child seed derived from that run seed.
The descent chain is deterministic, so replays work.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/core` holds run state and the descent chain.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same map.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Every floor of a run is solvable.
One seed replays every floor in order.

## Evaluation evidence

The suite has 69 tests.
It covers generation, biomes, combat, drops, pathfinding, and descent.
All 69 tests pass in a headless run.
A smoke test loads the game, spawns a run, and descends a floor.

## Roadmap

Complete:

- Multi-floor descent and a floor counter.
- Seeded replay across every floor.

Next:

- Add ranged monsters and projectiles.
- Add sound and music.
- Add more biomes and items.
- Add controller support.

## Limitations

The demo has three biomes.
Runs are capped at a few floors.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
