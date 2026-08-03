# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run descends through three new dungeons that you can explore and finish.

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

Dungeonwright generates a connected dungeon on every floor.
You explore rooms and corridors.
You find keys, open locked doors, and reach the exit.
The same seed always builds the same run.
A run ends when you clear the deepest floor.

## Features

- A new dungeon for every floor, driven by a seed.
- A run of three floors with a depth counter.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## First release

The first release shipped a playable demo.
The generator guaranteed the exit was always reachable.
You could walk, fight, collect loot, and finish a run.
You could replay any run from its seed.

## Second release

The second release added full gamepad support.
Every action had a gamepad binding.
Analog input got a deadzone and a diagonal speed cap.
Menus showed the controls for the active device.

## This release

This release adds a multi-floor descent.
A run now has three floors, and each floor is a fresh dungeon.
Every floor uses a different biome.
The hero keeps health and loot when they descend.
Keys reset, because each floor has its own doors.
The HUD shows the current floor and the run total.
The run summary shows how deep the hero reached.

Each floor derives its seed from the run seed.
A seed therefore replays the whole descent, floor for floor.

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

A run plan turns the run seed into one seed per floor.
Each floor seed mixes the run seed with the floor number.
The floor picks a biome from that seed.
The scene controller descends when the hero reaches an exit.
The last floor ends the run instead.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/core` holds the run state and the run plan.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, and pickups.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same run of floors.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.

## Evaluation evidence

The suite has 81 tests.
It covers generation, biomes, combat, drops, pathfinding, input, and descent.
All 81 tests pass in a headless run.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test also checks every action has a gamepad binding.
The smoke test then walks the hero to the exit and verifies the descent.

## Roadmap

Done in this release:
- Multi-floor descent with a depth counter.
- A fresh biome on every floor.
- Deterministic per-floor seeds.

Done in the second release:
- Full gamepad support.

Next up:
- Ranged monsters and projectiles.
- Sound and music.
- More biomes and items.

## Limitations

Each run has exactly three floors.
All monsters use melee attacks.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
