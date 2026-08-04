# Changelog

All notable changes to this project are listed here.
The format follows Keep a Changelog.
This project uses semantic versioning.

## [0.7.0] - 2026-08-04

Added

- A boss floor as the final floor of every run.
- The Warden, a two-phase boss that guards the exit.
- Melee slams and a three-bolt volley for the Warden.
- An enrage phase below half health.
- A boss health bar at the top of the screen.
- A relic item that the Warden drops on death.
- Victory on collecting the relic.
- An emblem item that boosts the hero's sword damage.
- A damage bonus that carries between floors.
- A boss music theme with a tense chord loop.
- A roar cue for the Warden's enrage.
- Pickup cues for the relic and the emblem.
- Art for the Warden, the relic, and the emblem.
- A sealed exit that opens when the boss falls.
- A camera shake when the Warden enrages.
- Unit tests for the boss spec, volley math, and loot items.
- Integration tests for the boss floor and the relic win.

Changed

- The exit no longer ends the final floor until the Warden dies.
- The beacon turns red while the Warden guards the exit.
- Monster drop tables now include a rare emblem entry.
- Emblems add damage to the hero's sword for the whole run.
- The boss theme replaces the biome theme on the final floor.

## [0.6.0] - 2026-08-04

Added

- Procedural sound effects generated entirely in code.
- Cues for attacks, hits, damage, deaths, shots, and impacts.
- Cues for bomb throws, bomb blasts, and door opens.
- A distinct pickup sound for every loot item.
- Stings for descent, victory, and defeat.
- A looping music theme for every biome.
- A menu theme that plays before a run starts.
- An audio controller with a pooled set of effect players.
- A waveform synthesis core with deterministic output.
- Unit tests for waveform math, the sound bank, and music themes.
- Smoke-test checks that every cue and every theme builds audio.

Changed

- The main scene now owns an audio controller node.
- The scene controller plays cues from its combat handlers.
- Music switches to the biome theme when a floor starts.
- Music stops when a run ends.

## [0.5.0] - 2026-08-04

Added

- A fourth biome, the Frost Vault, with icy generation rules.
- A new monster, the Hollow Wraith, that rushes the hero.
- A bomb consumable that monsters can drop.
- A thrown bomb with a fuse and a square blast radius.
- Bomb blast damage that scales with the hero's sword.
- HUD counters for shards and bombs.
- Art for the shard item.
- Unit tests for bomb flight and blast radius.
- Integration tests for bomb combat.

Changed

- Every monster drop table now includes a rare bomb entry.
- The input map has a throw action for keyboard and gamepad.

## [0.4.0] - 2026-08-04

Added

- A ranged monster, the Bone Archer, that fires bolts.
- A projectile system with deterministic tile-based flight.
- Line of sight checks across walls and locked doors.
- A bolt impact effect at the point of impact.
- Unit tests for line of sight and projectile flight.
- Integration tests for ranged combat.
- A smoke-test guard that checks monster specs and art exist.

Changed

- The crypt and ember stronghold monster tables now include archers.
- The world scene has a dedicated projectiles layer.

## [0.3.0] - 2026-08-03

Added

- Multi-floor descent across three floors.
- A floor counter in the HUD.
- Difficulty scaling for monsters on deeper floors.
- A heal between floors that keeps hero health.
- Loot that carries across floors.
- Run rules with deterministic per-floor seeds.
- Integration tests for the descent flow.

Changed

- Reaching the exit now descends until the final floor.
- Run summaries show the floor reached.
- Coins reset at the start of a new run.

## [0.2.0] - 2026-08-03

Added

- Full gamepad support for every action.
- Analog stick movement with a deadzone.
- Normalised diagonal movement speed.
- D-pad and stick bindings for all movement.
- Gamepad bindings for attack, pause, and new run.
- Control hints that match the active device.
- Unit tests for the input bindings and helpers.

## [0.1.0] - 2026-08-03

Added

- Seed-driven dungeon generation with three biomes.
- Rooms, corridors, locked doors, and keys.
- Monsters, melee combat, and drop tables.
- Deterministic replay from a seed string.
- Procedural tile art and a minimap.
- A headless test suite and a smoke test.
