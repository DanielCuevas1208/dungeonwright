# Dungeonwright

A seeded dungeon crawler built with Godot and GDScript.
Every run builds a new dungeon that you can explore and finish.
Descend three floors. Every floor grows harder.
The final floor is a boss fight.

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
Sound and music are generated in code.
The exit leads to the next floor.
After three floors, the run ends in victory.
The same seed always builds the same dungeon.

The main menu includes a biome gallery.
It previews real generated maps before you start a run.
It also includes a capture-ready showcase frame.
The frame explains one fixed run and can launch that seed.

## Features

- A new map for every run, driven by a seed.
- Three floors per run with a depth counter.
- Rooms, corridors, locked doors, and keys.
- Five biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Ranged monsters that fire dodgeable projectiles.
- A bomb item that blasts a crowd of monsters.
- A boss floor guarded by the Warden.
- The Warden fires bolt volleys and enrages below half health.
- A relic that ends the run when the Warden falls.
- An emblem item that boosts the hero's sword damage.
- Monsters grow stronger on deeper floors.
- Procedural pixel art with no bundled image files.
- Procedural sound and music with no bundled audio files.
- A minimap, a health bar, and run summary overlays.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.
- An in-game biome gallery for quick visual comparison.
- A capture-ready showcase frame for the featured biome.

## First release

This release ships a playable demo.
The generator guarantees the exit is always reachable.
You can walk, fight, collect loot, and finish a run.
You can replay any run from its seed.

## This release: Showcase frame

The menu now offers a capture-ready showcase frame.
It features the Tidebound Archive and its generated map.
The frame shows the replay seed, map facts, and reachability status.
Play this seed to move from the frame into a live run.

## Featured content: Tidebound Archive

This release adds the Tidebound Archive.
Flooded galleries use winding corridors and larger rooms.
Extra loops create more route choices.
Teal and amber tiles give the biome a clear identity.
Its procedural music theme uses a matching chord set.

The menu now includes a biome gallery.
Each page shows a deterministic map preview.
Palette swatches and threat icons explain the region.

The final floor still holds the Warden boss.

This release adds a boss floor.
The final floor is a sealed arena.
The Warden guards the exit.
It slams in melee and fires bolt volleys.
Below half health, it enrages and fights faster.
It drops a relic when it falls.
Collect the relic to win the run.
Monsters can now drop damage emblems.
Each emblem raises the hero's sword damage.
A tense theme plays while the Warden lives.

## Earlier releases

Release 0.6 added procedural audio.
Every sound effect is generated in code at run time.
Sword swings, hits, deaths, and explosions all have cues.
Each pickup has a distinct sound.
Every biome has its own looping music theme.
The menu plays a quiet theme of its own.
No audio files ship with the game.

Release 0.5 added a fourth biome and a bomb item.
The Frost Vault is a hall of blue ice.
Its corridors wind between vast frozen chambers.
A new monster, the Hollow Wraith, rushes the hero with speed.
It falls quickly once cornered.
Monsters can now drop bombs.
A thrown bomb lands, waits, and then blasts every monster in a radius.
The blast never hurts the hero.
The HUD shows the shards and bombs you carry.

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

Choose Browse biomes in the menu.
Use the buttons or arrow keys to change pages.
Press Escape to return to the menu.

Choose View showcase in the menu.
Press Play this seed to start the featured run.

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

The biome gallery uses the same generator.
Each preview uses a fixed seed.
The gallery never changes the active run.

The showcase uses one fixed Tidebound seed.
It uses `DungeonPreview` to render the same map data as the gallery.
The play action sends the replay seed through the normal menu start path.

Five biomes ship with the demo.
Each biome changes map dimensions, room rules, monster pressure, palette, and music.
The Tidebound Archive uses winding galleries, larger rooms, and frequent shortcut loops.

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

Audio is generated, never recorded.
The `Waveform` class synthesizes tones and noise bursts.
It applies attack and release so sounds do not click.
The `SoundBank` class builds every effect cue from these parts.
The `MusicTheme` class builds a looping pad for each biome.
An `AudioController` node plays effects and music.
It reuses a small pool of effect players.
Every stream is cached after its first build.
The same cue always produces the same sound.

The final floor is a boss floor.
The generator marks a tile next to the exit for the Warden.
The Warden chases the hero and slams in melee.
At range, it fires a fan of three bolts.
Below half health, it enrages.
An enraged Warden moves and attacks faster.
The exit stays sealed while the Warden lives.
When it falls, it drops a relic.
Collecting the relic wins the run.
The HUD shows a boss bar while the Warden lives.

Emblems are a rare monster drop.
Each emblem adds two points of sword damage.
The bonus lasts for the whole run.
It carries between floors.

## Project layout

- `scripts/dungeon` holds the generator and map logic.
- `scripts/combat` holds stats, monsters, and loot tables.
- `scripts/audio` holds the sound synthesis and music themes.
- `scripts/core` holds run rules and shared run state.
- `scripts/input` holds the controls helper.
- `scripts/world` renders tiles and builds the minimap.
- `scripts/actors` holds the hero, monsters, pickups, and projectiles.
- `scripts/ui` builds the HUD and overlays.
- `scripts/ui/dungeon_preview.gd` renders deterministic map previews.
- `scenes` holds the scene tree.
- `scenes/ui/showcase.tscn` holds the capture-ready showcase view.
- `tests` holds the GUT suite.
- `tools` holds the setup, test, and CI scripts.

Read [docs/architecture.md](docs/architecture.md) for the system design.

## Design guarantees

A seed always produces the same map.
A seed always produces the same floor sequence.
Doors never block the exit permanently.
Every key sits on the reachable side of its door.
Monsters never cross a locked door.
Bolts stop at walls and locked doors.
Monsters never fire through a solid wall.
A cue always produces the same sound.
Every biome has a music theme.
A boss floor seals the exit until the Warden falls.
The Warden always drops a relic when it dies.

## Evaluation evidence

It covers generation, all five biomes, combat, drops, pathfinding, input, floors, projectiles, bombs, and audio.
It covers the boss floor, bolt volleys, enrage, relic victory, and gallery previews.
It also covers the showcase seed, preview size, replay stability, and view state.
The suite has 215 tests and 5,047 assertions.
All 215 tests pass in a headless run.
Run the full suite before release.
A smoke test loads the game and spawns a fixed-seed run.
The smoke test passes with seed 12345.
The smoke test checks the hero descends after reaching the exit.
The smoke test checks the boss floor spawns a Warden and a relic.
The smoke test checks every action has a gamepad binding.
The smoke test checks every monster and every drop item has art.
The smoke test checks every sound cue and every music theme builds audio.

CI imports the project, runs GUT, runs the smoke test, and uploads the test report.
Local status depends on the installed Godot version.

Validation status:

- CI is configured for Godot 4.6.1.
- Local GUT validation passes with 215 tests and 5,047 assertions.
- Local smoke validation passes with seed 12345.

## Sample output

The smoke test prints this success line:

`Smoke test passed: seed 12345 spawned a solvable dungeon across floors.`

The gallery shows one generated map for each biome.

The showcase displays:

`Replay seed: 0000ZJ`

`Exit reachable: yes`

## Roadmap

Done in this release:
- The capture-ready showcase frame.
- A fixed featured seed with a play action.
- The biome gallery with deterministic map previews.
- Palette swatches and common threat icons.
- The Tidebound Archive, a fifth biome with winding galleries.
- A matching procedural music theme.
- A boss floor that seals the exit.
- The Warden, with melee slams, bolt volleys, and enrage.
- A relic that drops when the Warden falls.
- An emblem item that boosts sword damage.
- A boss music theme and a boss health bar.

Done in an earlier release:
- Procedural sound effects for combat, pickups, doors, and results.
- A distinct looping music theme for every biome.
- A fourth biome, the Frost Vault.
- The Hollow Wraith monster.
- A bomb item with a blast radius.
- Ranged monsters and dodgeable projectiles.
- Multi-floor descent with a depth counter.
- Full gamepad support.

Next up:
- A new item type with a focused use.

Read the full release plan in [docs/roadmap.md](docs/roadmap.md).

## Limitations

The demo has five biomes.
Each run spans three floors.
One boss type guards the final floor.
The hero has one melee attack and one thrown item.
Audio is instrumental, with no voice lines.
Gallery previews use fixed seeds.
Gallery previews do not replace a live run.
The showcase features one fixed biome.
The showcase frame does not replace a live run.

## License

MIT.
See the LICENSE file for details.
