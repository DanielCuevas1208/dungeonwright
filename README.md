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
You can throw bombs you loot from monsters.
The exit leads to the next floor.
After three floors, the run ends in victory.
The same seed always builds the same dungeon.

## Features

- A new map for every run, driven by a seed.
- Three floors per run with a depth counter.
- Rooms, corridors, locked doors, and keys.
- Four biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Ranged monsters that fire dodgeable projectiles.
- A bomb item that blasts a crowd of monsters.
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

This release adds a fourth biome and a bomb item.
The Frost Vault is a hall of blue ice.
Its corridors wind between vast frozen chambers.
A new monster, the Hollow Wraith, rushes the hero with speed.
It falls quickly once cornered.
Monsters can now drop bombs.
A thrown bomb lands, waits, and then blasts every monster in a radius.
The blast never hurts the hero.
The HUD shows the shards and bombs you carry.

## Earlier releases

Release 0.4 added ranged combat.
The Bone Archer fires bolts at the hero.
Archers hold their ground and shoot when they can see you.
Bolts fly straight until a wall stops them.
The hero can dodge a bolt by moving off its line.

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
Throw a bomb with B.
Press N for a new run.
Press M to toggle the minimap.
Press Escape to pause.

A gamepad works too.
Move with the left stick or the d-pad.
Attack with A or the right shoulder button.
Throw a bomb with X.
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

Bombs give the hero an area attack.
A monster drop can carry a bomb.
The hero throws a bomb two tiles ahead.
Walls stop a thrown bomb.
After a short fuse, the bomb blasts every monster in a square radius.
The blast damage scales with the hero's sword.

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

The suite has 137 tests.
It covers generation, biomes, combat, drops, pathfinding, input, floors, projectiles, and bombs.
All 137 tests pass in a headless run.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test checks the hero descends after reaching the exit.
The smoke test checks every action has a gamepad binding.
The smoke test checks every monster and every drop item has art.

## Roadmap

Done in this release:
- A fourth biome, the Frost Vault.
- The Hollow Wraith monster.
- A bomb item with a blast radius.
- HUD counters for shards and bombs.

Done in an earlier release:
- Ranged monsters and dodgeable projectiles.
- Multi-floor descent with a depth counter.
- Full gamepad support.

Next up:
- Sound and music.
- More items and a boss floor.

## Limitations

The demo has four biomes.
Each run spans three floors.
The hero has one melee attack and one thrown item.
The game has no audio yet.

## License

MIT.
See the LICENSE file for details.
