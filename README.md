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
The same seed always builds the same run.
The run descends through several floors.

## Features

- A new map for every run, driven by a seed.
- Multi-floor runs that descend into a new dungeon.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
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

This release adds a multi-floor descent.
Every run now spans several floors.
The exit on a floor leads down to the next floor.
One seed replays the whole run, floor by floor.
Coins and shards carry over between floors.
The run ends when you clear the final floor.

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
Reach the exit to descend to the next floor.
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

A run has more than one floor.
Each floor builds a fresh dungeon from a child seed.
The child seed comes from the run seed through a fixed mixer.
So one seed replays every floor in the same order.
Coins and shards carry over between floors.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/core` holds the run state and the descent seed chain.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same floors.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.

## Evaluation evidence

The suite has 81 tests.
It covers generation, biomes, descent, combat, drops, pathfinding, and input.
All 81 tests pass in a headless run.
A smoke test loads the game and clears a fixed-seed run floor by floor.
The smoke test also checks every action has a gamepad binding.

## Roadmap

Done in this release:
- Multi-floor descent with a floor counter.

Next up:
- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
Each run stays inside one biome.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
