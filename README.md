# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run builds a new dungeon that you can explore and finish.
Descend three floors. Every floor grows harder.

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
Some monsters fight from a distance.
The exit leads to the next floor.
After three floors, the run ends in victory.
The same seed always builds the same dungeon.

## Features

- A new map for every run, driven by a seed.
- Three floors per run with a depth counter.
- Rooms, corridors, locked doors, and keys.
- Three biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Ranged monsters that fire dodgeable projectiles.
- Monsters grow stronger on deeper floors.
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

This release adds ranged combat.
A new monster, the Bone Archer, fires bolts at the hero.
Archers hold their ground and shoot when they can see you.
Line of sight checks walls and locked doors.
Bolts fly straight until a wall stops them.
A bolt fades after a fixed travel distance.
The hero can dodge a bolt by moving off its line.
The crypt and the ember stronghold now hold archers.

## Earlier releases

Release 0.3 added multi-floor descent.
A run spans three floors.
Each floor is a new solvable dungeon.
Monsters grow stronger with depth.
The hero keeps health and loot between floors.
Keys reset when the hero descends.
The hero heals a little on each descent.
The HUD shows the current floor.

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

A run descends through three floors.
`RunRules` sets the floor count and the difficulty curve.
Each floor uses a seed derived from the run seed.
Floor one uses the run seed itself.
Deeper floors mix the run seed with the floor number.
The hero keeps health and loot between floors.
Monsters use scaled stats on deeper floors.
The run ends on the final floor.

Ranged monsters add a second combat layer.
An archer fires when the hero is in range and visible.
A `Combat` helper checks line of sight between tiles.
Bolts carry a speed, a direction, and a range.
Walls and locked doors stop a bolt.
The hero can sidestep a bolt because bolts take time to arrive.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/core` holds run rules and shared run state.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, pickups, and projectiles.
- `scripts/ui` builds the HUD and overlays.
- `scenes` holds the scene tree.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

## Design guarantees

A seed always produces the same map.
A seed always produces the same floor sequence.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Bolts stop at walls and locked doors.
Monsters never fire through a solid wall.

## Evaluation evidence

The suite has 114 tests.
It covers generation, biomes, combat, drops, pathfinding, input, floors, and projectiles.
All 114 tests pass in a headless run.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test checks the hero descends after reaching the exit.
The smoke test checks every action has a gamepad binding.
The smoke test checks every monster has art and a valid spec.

## Roadmap

Done in this release:
- Ranged monsters and dodgeable projectiles.

Done in an earlier release:
- Multi-floor descent with a depth counter.
- Full gamepad support.

Next up:
- Sound and music.
- More biomes and items.

## Limitations

The demo has three biomes.
Each run spans three floors.
The hero has one melee attack only.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
