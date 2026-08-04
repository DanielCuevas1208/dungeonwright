# Dungeonwright

A seeded dungeon crawler built with Godot.
Every run forges a new dungeon that you must conquer.

```
####.D.############
##.........####..###
#######.#####.#..#E#
##...##......##.#..#
##.D.###.####.#####.
##......##.....#...#
##########.D..######
```

## The dungeon

Dungeonwright draws a new map for every run.
You explore rooms, corridors, and locked halls.
You collect keys, open doors, and reach the exit.
The same seed always forges the same dungeon.

## What this release adds

This release adds ranged combat.
Three new monsters attack from a distance.
They fire bolts, spit, and burning embers across rooms.
Close the gap or break line of sight to survive.
Dodgeable shots add tension to every corridor fight.

## Features

- A new map for every run, driven by a seed.
- Rooms, corridors, locked doors, and keys.
- Three biomes with distinct generation rules.
- Melee monsters and three new ranged monsters.
- Projectiles that stop at walls and locked doors.
- Procedural pixel art with no bundled images.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.

## First release

This release ships a playable demo.
The generator guarantees the exit is always reachable.
You can walk, fight, dodge, loot, and finish a run.
You can replay any run from its seed.

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

The generator follows a fixed pipeline.
It places rooms, connects them with corridors, and carves the map.
It picks the farthest room as the exit.
It places doors on corridors and puts each key on the safe side.
A solver then proves the dungeon can be completed.

The generation code is pure data.
It has no scene nodes, so tests run fast and deterministic.
The scene controller turns the map into a live game.

Ranged monsters keep their distance.
They fire only when they can see the hero.
A Bresenham walk checks every tile between them.
Walls and locked doors stop each projectile.

The projectile is a plain node.
It flies in a straight line toward its target.
It despawns after its range or on impact.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/actors` holds the hero, monsters, and projectiles.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/input` holds the controls helper.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same map.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Projectiles never cross a wall or a locked door.

## Evaluation evidence

The suite has 85 tests.
It covers generation, biomes, combat, drops, pathfinding, input,
and ranged combat.
All 85 tests pass in a headless run.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test also checks gamepad bindings and ranged rules.

## Roadmap

Done in this release:
- Ranged monsters and projectiles.

Done in earlier releases:
- Seeded generation, rooms, doors, and keys.
- Combat, monsters, and loot tables.
- Procedural art, a minimap, and run overlays.
- Full gamepad support.

Next up:
- Multi-floor descent and a depth counter.
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
Each run is a single floor.
Projectiles fly straight and never home in.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
