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
- Four biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Permanent upgrade items dropped by monsters.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.

## This release

This release adds a fourth biome and permanent upgrades.
The Sunken Ruins flood the map with wide winding corridors.
Riptides, a new fast monster, patrol the flooded halls.

Monsters rarely drop upgrade items.
A whetstone raises your attack damage by 2.
A relic raises your max health by 10 and heals you.
The HUD shows the bonuses you have collected.

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

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

Items use a small registry.
Each item has an id, a name, and a category.
Loot tables roll a weighted entry.
Upgrades mutate the hero stats through one pure function.
The same seed always produces the same drops.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, items, and loot tables.
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
Upgrade items never change the generated map.

## Evaluation evidence

The suite has 70 tests.
It covers generation, biomes, combat, drops, pathfinding,
and the item registry.
All 70 tests pass in a headless run.
A smoke test loads the game, spawns a fixed-seed run,
and checks the Sunken Ruins and the upgrade effects.

## Roadmap

Complete:

- More biomes and items.
- The Sunken Ruins biome and the Riptide monster.
- Whetstone and relic permanent upgrades.

Next:

- Add controller support.

## Limitations

The demo has four biomes.
Each run is a single floor.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
