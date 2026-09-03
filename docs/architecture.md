# Architecture

This document explains the design of Dungeonwright.
It covers the generation pipeline, the combat model, and the scene flow.

## Generation pipeline

The generator lives in `scripts/dungeon`.
It reads a seed and a biome, and it returns a `DungeonResult`.
The result holds the map, rooms, corridors, and all placed features.

The pipeline runs in a fixed order.

1. Place rooms without overlaps.
2. Connect every room with a spanning tree of corridors.
3. Add optional shortcut corridors for loops.
4. Carve the biome corridor style into the map.
5. Choose the start and the farthest room as the exit.
6. Place doors and keys.
7. Place shrines in room interiors.
8. Scatter monsters in the rooms.

The generator also marks a walkable tile next to the exit.
This tile holds the final-floor boss and is stored in the result.

### Room placement

The generator draws random rectangles in the map bounds.
It rejects a room when it overlaps an existing room.
It repeats until it reaches the target room count.

### Connectivity

A Prim-like loop links every unconnected room to its nearest neighbor.
The result is a spanning tree, so the map is connected by construction.
Shortcuts add loops so the player has more than one path.

### Corridor styles

Each biome picks a carving style.

- Elbow: an L-shaped path with one bend.
- Winding: a path of short, jittered runs.
- Straight: a path that favors one axis at a time.

All carvers keep every carved cell orthogonally adjacent to the path.
This rule prevents floating single-cell islands.

Five biomes ship with the game.
The Frost Vault uses the winding style and large rooms.
The Tidebound Archive uses winding corridors, larger rooms, and frequent loops.
Each biome defines its own palette, doors, monsters, and pressure.

### Doors and keys

Doors sit on tree corridors.
The generator chooses a walkable tile near the middle of a corridor.

Keys must be reachable before their door opens.
The generator simulates the run to enforce this rule.
It floods the map from the start with every door locked.
It places the current door key inside that reachable region.
Then it opens the door and repeats for the next door.

This method survives corridor crossings.
A door tile can block another corridor on the map.
The simulation still finds a valid opening order.

### Solvability

The `Solvability` class proves a dungeon can be finished.
It replays the flood with a real key and door model.
A locked door opens only after the player finds its key.
The generator runs this check on every map.
The test suite treats the check as a core property.

## Seeded randomness

All randomness uses `SeededRng`.
The class wraps the mulberry32 algorithm.
The output depends only on the seed, never on the platform.
Seeds display as six-character base-36 strings.

A run uses one run seed.
Each floor derives its dungeon seed from that run seed.
`RunRules.floor_seed` mixes the run seed with the floor number.
Floor one uses the run seed unchanged.

## Combat model

The player and each monster carry a `CombatStats` block.
Pure functions in `scripts/combat` compute damage.
Attack range and facing arcs use tile math, not physics.

The player attacks in a facing arc.
Monsters chase, stalk, or hold ground according to their spec.
Each monster rolls loot from a weighted `DropTable`.
Coins drop often, shards sometimes, potions rarely, bombs, emblems, and aegis crests rarest.

## Ranged combat

Archers fire projectiles at the hero.
The `Combat` class provides two helpers for ranged attacks.
`has_line_of_sight` checks every tile between two cells.
A wall or a locked door blocks the line.
`direction_toward` returns the eight-direction step toward a target.

A `Projectile` node carries the shot.
It holds a damage value, a speed, a direction, and a range.
The scene controller calls `tick` every frame.
A bolt moves one tile at a time toward its direction.
Walls, locked doors, and the map edge stop a bolt.
A bolt expires when its range runs out.
When a bolt reaches the hero's tile, it calls `take_damage`.

Archers aim at the hero's current tile.
Bolts take time to arrive, so the hero can dodge.
An archer holds its ground while it has line of sight.
Without line of sight, the archer closes the distance.
A melee monster never fires a bolt.

## Bomb combat

Bombs give the hero an area attack.
A monster drop can carry a bomb.
The hero throws a bomb in the facing direction.
The bomb starts one tile in front of the hero.

A `Bomb` node carries the throw.
It holds a damage value, a speed, a direction, a throw range, a fuse, and a blast radius.
The scene controller calls `tick` every frame.
A bomb travels forward until a wall or the map edge stops it.
It then sits on that tile while the fuse counts down.
When the fuse ends, the controller damages every monster in the blast radius.
A `Combat` helper checks the square radius around the blast center.
The blast damage scales with the hero's sword damage.
The blast never hurts the hero.

## Audio

All audio is generated in code at run time.
The game ships no sound files, matching the art pipeline.

The `Waveform` class in `scripts/audio` is the synthesis core.
It builds tones, glides, noise, envelopes, and mixing.
Every function takes explicit inputs and returns a sample buffer.
The output is deterministic, so tests can compare buffers exactly.
The `pack_wav` helper turns a buffer into a 16-bit mono stream.

The `SoundBank` class builds every effect cue.
Each cue layers short tones and noise bursts into one stream.
Cues exist for attacks, hits, deaths, shots, bombs, pickups, doors, and results.
The bank caches every stream after its first build.

The `MusicTheme` class builds a looping theme for each biome.
A theme is a chord pad with a bass line and a soft arpeggio.
Each biome has its own note and level table.
The menu plays its own quiet theme.
The Tidebound Archive has its own chord and level table.

The `AudioController` node owns the players.
It keeps a small pool of effect players and one music player.
The players keep running while the game is paused.
The controller switches music on each descent.
The music stops when a run ends.
The scene controller calls the audio cues from the same handlers that drive combat.

## Scene flow

The `Main` scene owns the game loop.
It generates a map and spawns the world.
The hero, monsters, pickups, and shrines are plain nodes.
The hero moves tile to tile with smooth interpolation.
Monsters follow short flood-fill paths.

The world renders from a tile map.
A `TileArt` class draws every sprite from pixel patterns.
The biome palette recolors the tiles at run time.

## Shrine offers

`ShrineOffer` stores the cost, names, descriptions, and combat bonuses.
It exposes two offers: Might adds four sword damage, and Ward adds two defence.
Both offers cost three shards.

The generator selects the offer with `SeededRng`.
It places one or two shrines in non-start and non-exit room interiors.
It avoids keys, doors, and the start and exit cells.

The live `ShrineActor` presents the generated record on the map.
The hero presses E, or the gamepad B button, while standing on its tile.
The actor becomes spent after a successful purchase.
The player applies the bonus to current stats and tracks its floor total.
`Main` clears that total before generating the next floor.

The shrine actor uses the same procedural entity art system.

## Biome gallery

The main menu can open the biome gallery while the game is paused.
`BiomeGallery` uses the same generator as a live run.
Each biome receives a fixed preview seed.
The gallery renders the map, palette swatches, and configured monster art.
This keeps the showcase view aligned with game content.
The gallery does not modify run state.

## Showcase frame

The main menu can open the showcase frame while the game is paused.
`ShowcaseOverlay` selects the Tidebound Archive and one fixed seed.
`DungeonPreview` renders the generated map for both the gallery and showcase.
The frame also reads room, door, threat, and map data from `DungeonResult`.
The play action sends the displayed seed through the normal start path.
This keeps the captured evidence and live run on the same code path.

## Run statistics

`RunStats` stores counters for the active run.
The main controller records actual enemy health removed after each player attack and bomb blast.
The player reports damage absorbed by defence through a signal.
The controller records each thrown bomb.
The counters continue across floor descent and reset at run start.
`ResultOverlay` reads the counters when it builds the final summary.

## Floor descent

A run spans three floors.
`RunRules` in `scripts/core` defines the run.
It holds the floor count, the difficulty curve, and the heal rate.

Each floor uses a derived seed.
Floor one uses the run seed unchanged.
Deeper floors mix the run seed with the floor number.
This keeps every run replayable from one seed.

The hero keeps health and loot between floors.
Keys reset, because each floor has its own doors.
The hero heals a fraction of missing health on descent.
Monsters use scaled stats on deeper floors.

The scene controller descends when the hero reaches the exit.
The run ends when the hero clears the final floor.
`MonsterSpec.scaled` copies a spec with stronger health and damage.
The generator and the rest of combat stay unchanged.

Ranged monsters share the same scene flow.
An archer emits `ranged_fired` when it shoots.
The controller spawns a `Projectile` in the world.
It refreshes the bolt's target tile to follow the hero.
A bolt that lands on the hero damages the hero.

## Boss floor

The final floor is a boss floor.
`RunRules.is_boss_floor` returns true for the last floor.
The generator marks a walkable tile next to the exit.
This tile becomes `boss_spawn` in the result.
The controller spawns the Warden there.

The Warden is a two-phase boss.
It chases the hero and slams in melee at close range.
At range, it fires a fan of three bolts.
A `Combat.volley_directions` helper spreads the aim line.
Each bolt is a normal `Projectile` the hero can dodge.
Below half health, the Warden enrages.
It moves faster, attacks faster, and turns red.
The boss bar in the HUD tracks the fight.

The exit stays sealed while the Warden lives.
`Main._exit_clear` blocks the exit until the boss falls.
When the Warden dies, it drops a relic.
The relic is a pickup with its own sound and art.
Collecting the relic calls the victory flow.
The run can no longer end by walking to the exit first.

Monsters can drop damage emblems and protective aegis crests.
An emblem adds two points to the hero sword damage.
An aegis crest adds one point of defence to the hero armour.
Defence reduces incoming combat damage, but never below one minimum damage.
The hero carries both bonuses between floors for the entire run.
The HUD counts both items in the active loot row.
The boss theme plays on the boss floor.
The beacon turns red while the Warden guards the exit.

## Input handling

A `Controls` class reads all movement input.
It combines the keyboard and the first connected gamepad.
It applies a deadzone so a resting stick stays still.
It caps diagonal speed at one.
The hero reads its movement from this class.

Every action has a keyboard and a gamepad binding.
The input map in `project.godot` holds both sets.
Menus ask `Controls` for the correct labels.
The hints update when a gamepad connects or disconnects.

## Testing

The suite runs headless with GUT.
Unit tests cover the RNG, generator, biomes, combat, drops, and run rules.
Unit tests also cover line of sight, projectile flight, and bomb flight.
Unit tests also cover waveform math, every sound cue, and every music theme.
Unit tests also cover the boss spec, enrage profile, and volley math.
Unit tests also cover every biome rule and the Tidebound Archive replay.
Unit tests also cover shared map previews and the showcase replay seed.
Unit tests also cover the aegis defence formula, pickup events, and drop weights.
Unit tests also cover shrine offers, placement, purchases, and floor expiry.
Integration tests run many seeds across all biomes.
Integration tests also drive the floor descent flow.
Integration tests verify archers fire and bolts damage the hero.
Integration tests verify bombs blast the monsters they should.
Integration tests verify the boss floor seals the exit and drops the relic.
Integration tests verify aegis defence reduces damage during live combat.
Every generated dungeon must be solvable.
Each floor must be a fresh solvable dungeon.
The final floor must spawn a boss and a relic.
Every generated shrine must use a valid offer and a unique interior cell.

Run the suite with `tools/run_tests`.
CI runs the same commands on every push.
