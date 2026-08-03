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
You find keys, open locked doors, and reach the exit.
The same seed always builds the same dungeon.

## Features

- A new map for every run, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Melee monsters with simple combat and balanced drops.
- Ranged monsters that fire projectiles from a distance.
- Procedural pixel art with no bundled image files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.

## This release

This release adds ranged monsters and projectiles.
Shooter monsters hold a firing range and attack on line of sight.
Their projectiles travel in straight lines and stop at walls.
The hero can dodge a projectile or block it with a wall.
Each biome has its own shooter and its own projectile.

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
Dodge projectiles by stepping off their line.
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

Ranged monsters use line-of-sight checks.
A shooter fires only when it can see the hero.
Walls and locked doors block the line of sight.
Projectile flight is pure math, so it stays deterministic.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, projectiles, and loot.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, pickups, and projectiles.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same map.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Shooters only fire when a clear line of sight exists.

## Evaluation evidence

The suite has 77 tests.
It covers generation, biomes, combat, drops, pathfinding,
projectiles, and ranged behaviour.
All 77 tests pass in a headless run.
A smoke test loads the game, spawns a fixed-seed run, and fires
a projectile at the hero.

## Roadmap

Complete:

- Ranged monsters and projectiles.
- Line-of-sight checks for ranged attacks.

Next:

- Add multi-floor descent and a depth counter.
- Add sound and music.
- Add more biomes and items.
- Add controller support.

## Limitations

The demo has three biomes.
Each run is a single floor.
Projectiles follow straight lines only.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
