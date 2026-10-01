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

## Value

Dungeonwright generates connected, solvable dungeons on every run.
You explore rooms and corridors.
You find keys, open locked doors, and reach the exit.
Monsters fight in melee or shoot from a distance.
You can throw bombs and gather damage emblems or defensive aegis crests.
All pixel art and sound effects generate in code at run time.
Every run replays identically from its seed.

The main menu includes a biome gallery.
It previews real generated maps before you start a run.
It also includes a capture-ready showcase frame.
The frame explains one fixed run and can launch that seed.

Shrines offer a clear choice during exploration.
Spend three shards for Might or Ward.
Each blessing lasts for the current floor.

## Features

- A new map for every run, driven by a seed.
- Three floors per run with a depth counter.
- Rooms, corridors, locked doors, and keys.
- Five biomes with different generation rules.
- Monsters with simple combat and balanced drops.
- Ranged monsters that fire dodgeable projectiles.
- A bomb item that blasts a crowd of monsters.
- An emblem item that boosts sword damage.
- An aegis crest that absorbs incoming damage.
- A boss floor guarded by the Warden.
- The Warden fires bolt volleys and enrages below half health.
- A relic that ends the run when the Warden falls.
- Monsters grow stronger on deeper floors.
- Procedural pixel art with no bundled image files.
- Procedural sound and music with no bundled audio files.
- A minimap, a health bar, and run summary overlays.
- Run statistics for damage dealt, damage blocked, and bombs thrown.
- Deterministic generation for replayable runs.
- Full gamepad support with analog movement.
- An in-game biome gallery for quick visual comparison.
- A capture-ready showcase frame for the featured biome.
- Interactive shrines that trade shards for floor-only combat buffs.
- Persistent run history that survives game launches.

## This release: Persistent run history

The result screen keeps the five latest completed runs.
Each entry shows the outcome, seed, reached floor, coins, time, and combat totals.
The history uses copied data, so a new run cannot change an older entry.
Dungeonwright stores records in versioned JSON at `user://dungeonwright_run_history.json`.
The game saves after every completed run.
The result screen clears saved records after confirmation.
Missing data starts with an empty history.
Invalid records are skipped.

## Previous release: Interactive shrines

Each generated floor places one or two shrines in room interiors.
Shrines offer Might or Ward from a seeded offer table.
Press E when the hero stands on a shrine.
Spend three shards to gain four sword damage or two defence.
The HUD lists active floor buffs.
Shrines become spent after one purchase.
Buffs clear when the hero descends.

The result screen reports three combat counters.
It shows enemy health removed, damage absorbed by defence, and bombs thrown.
Counters cover every floor and reset when a new run starts.

## Previous release: Aegis Crest

That release added the Aegis Crest defensive item.
Monsters can now drop aegis crests.
Each crest adds one point of defence to the hero.
Defence absorbs incoming melee and projectile damage.
Damage never falls below the minimum of one point.
The hero carries defence bonuses across all floors.
The HUD displays held crests in the bottom loot row.

## Architecture

The project separates pure generation logic from the live scene.

- `scripts/dungeon`: Pure data dungeon generator, spanning-tree corridor carvers, and solvability verifier.
- `scripts/combat`: Pure combat math, monster specifications, and weighted drop tables.
- `scripts/actors`: Hero, monsters, projectiles, bombs, and collectible pickups.
- `scripts/audio`: Procedural waveform synthesis, sound bank cues, and looping biome music themes.
- `scripts/core`: Deterministic multi-floor rules and runtime state tracking.
- `RunStats` keeps run counters separate from the live scene.
- `RunHistory` snapshots completed runs and persists them for the result overlay.
- `ShrineOffer` keeps shrine costs and effects in pure data.
- `scripts/ui`: In-game HUD, pause menu, biome gallery, and showcase overlay.
- `scripts/world`: Procedural pixel art, map rendering, and shrine actors.

Read [docs/architecture.md](docs/architecture.md) for detailed architecture documentation.

## Requirements

- Godot 4.6 or newer.

## Setup

1. Install Godot 4.6 from the official site.
2. Clone this repository to your computer.
3. Set `GODOT_BIN` to the Godot executable path.
4. Run `tools/run_game.ps1` on Windows.
5. Run `tools/run_game.sh` on Linux or macOS.

The scripts find Godot on PATH automatically.
On Windows they also search common install locations.

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

Stand on a shrine and press E to inspect or buy its offer.

A gamepad works too.
Move with the left stick or the d-pad.
Attack with A or the right shoulder button.
Throw a bomb with X.
Press B at a shrine.
Press Y for a new run.
Press Select to toggle the minimap.
Press Start to pause.

## Tests and validation

Run `tools/run_tests.ps1` on Windows.
Run `tools/run_tests.sh` on Linux or macOS.

The script installs GUT, imports the project, and runs the suite.
Tests run headless, so no window opens.

Test status:
- 260 tests pass across 27 test scripts with 5,319 assertions.
- 0 failing tests and 0 deprecation warnings.
- Result screens show damage dealt, damage blocked, and bombs thrown.
- Persistence tests cover round trips, invalid data, retention, and clearing.
- Headless smoke test passes with seed 12345.
- GitHub Actions CI workflow validates pushes and pull requests.

## Sample output

Headless smoke test output:

```
[smoke] loading main scene
[smoke] scene added
[smoke] starting run with seed 12345
Smoke test passed: seed 12345 spawned a solvable dungeon across floors.
```

GUT test suite summary:

```
==============================================
= Run Summary
==============================================

Totals
------
Scripts              27
Tests               255
Passing Tests       255
Asserts            5301
Time              <duration>

---- All tests passed! ----
```

Result screen counters:

```
Damage dealt: <enemy health removed>
Damage blocked: <damage absorbed>
Bombs thrown: <bombs used>
```

Recent run history:

```
Recent runs (saved between launches)
1. WON | 0000ZJ | F3/3 | 4c | 0:10 | dmg 42 blk 8 bomb 1
```

Shrine prompt:

```
Shrine of Might: Sword damage +4 this floor | 3 shards | Press E
```

## Limitations

The game includes five biomes.
Each run spans three floors.
One boss type guards the final floor.
The hero has one melee attack and one thrown bomb.
Audio is instrumental, with no voice acting.
Gallery previews use fixed seeds.
The showcase frame features one fixed biome.
Run history stores five completed runs.
Run history stores no dates, screenshots, or personal information.
Shrine buffs expire on floor descent and are not saved.

## Roadmap

Done in this release:
- Interactive room shrines with deterministic Might and Ward offers.
- Single-floor buffs that consume three shards.
- Shrine prompts, procedural art, activation audio, and HUD buff state.
- Unit and smoke coverage for shrine placement, purchase, and expiry.
- Run statistics on the result screen.
- The Aegis Crest defensive item and damage absorption.
- Carried defence bonuses across multi-floor runs.
- Procedural pixel art and pickup audio for the Aegis Crest.
- HUD armour counter in the loot row.
- Unit and integration tests for defence scaling and drop balance.
- Bounded run history with copied completion records.
- Result-screen history for wins and defeats.
- Versioned JSON storage for five completed runs.
- Confirmed clearing for saved history.
- Unit and integration tests for history ordering, retention, storage, and reset.

Done in earlier releases:
- Capture-ready showcase frame and biome gallery.
- Tidebound Archive biome and matching music theme.
- Boss floor with the Warden and relic victory.
- Damage emblems and bomb combat.
- Procedural waveform audio synthesis and sound bank.
- Ranged combat with Bone Archers and dodgeable bolts.
- Multi-floor descent with difficulty scaling.

Next up:
- Review whether the main menu should expose saved history before a new run.
- Keep the storage format versioned before adding more record fields.

Read the full release plan in [docs/roadmap.md](docs/roadmap.md).

## License

MIT.
See the LICENSE file for details.
