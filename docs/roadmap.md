# Roadmap

This roadmap tracks shipped work and the next release slice.

## 0.15.0 - Persistent run records

- Saved the five latest completed runs between launches.
- Added versioned JSON storage under Godot's user-data directory.
- Added safe handling for missing, malformed, and unknown-version data.
- Added a confirmed clear action on the result screen.
- Added unit and integration coverage for storage and reset behavior.

## 0.14.0 - Run history

- Added a bounded history for the five latest completed runs.
- Added copied run counters for stable result records.
- Added compact history entries to the victory and defeat overlay.
- Added tests for ordering, retention, copying, and result display.

## 0.13.0 - Interactive shrines

- Added deterministic room-interior shrine placement.
- Added Might and Ward offers that cost three shards.
- Added floor-only damage and defence buffs.
- Added interaction prompts, activation audio, and procedural shrine art.
- Added deterministic unit and smoke coverage.

## 0.12.0 - Run statistics

- Added damage dealt, damage blocked, and bombs thrown counters.
- Kept counters across floor descent.
- Reset counters at the start of each run.
- Added result-screen summary lines.
- Added deterministic unit and integration coverage.

## Released

### 0.11.0 - Aegis Crest

- Added the Aegis Crest defensive item.
- Added damage absorption that scales with held crests.
- Added procedural crest pixel art and pickup audio.
- Added HUD armour counters and carried defence between floors.
- Added unit and integration tests for defence and drops.

### 0.10.0 - Showcase Frame

- Added a capture-ready frame to the main menu.
- Added a fixed Tidebound Archive preview.
- Added replay seed, map facts, and reachability status.
- Added a direct action to play the featured seed.

### 0.9.0 - Biome Gallery

- Added a browseable gallery to the main menu.
- Added deterministic map previews for every biome.
- Added palette swatches and common threat icons.
- Added tests for stable previews and solvability.

### 0.8.0 - Tidebound Archive

- Added a fifth biome.
- Added winding galleries with larger rooms.
- Added a high-loop exploration layout.
- Added a teal and amber palette.
- Added a matching ambient music theme.
- Added deterministic biome tests.

### 0.7.0 - The Warden

- Added the sealed boss floor.
- Added the Warden and its enrage phase.
- Added relic victory and emblem damage.
- Added boss music and the health bar.

### 0.6.0 - Procedural Audio

- Added generated sound effects.
- Added looping themes for every biome.

### 0.5.0 - Frost Vault

- Added the Frost Vault.
- Added the Hollow Wraith.
- Added bombs and area damage.

### 0.4.0 - Ranged Combat

- Added archers and dodgeable bolts.
- Added line-of-sight checks.

### 0.3.0 - Multi-Floor Runs

- Added three-floor runs.
- Added deterministic floor seeds.

## Milestones

### history-menu

Status: complete.

User-visible outcome: Players can review saved runs before starting a new run.

Bounded deliverable: Main-menu history view with versioned loading and confirmed clearing.

Acceptance criteria:

- The menu shows the five newest completed runs.
- Missing and corrupt files show an empty history.
- Opening history does not start or change a run.
- Clearing requires confirmation and writes an empty versioned store.

Verification: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

### seeded-challenges

Status: planned.

User-visible outcome: Players can replay a shareable challenge with fixed rules.

Bounded deliverable: Encode the seed, generator version, and bounded modifiers in a challenge code.

Acceptance criteria:

- Challenge codes round trip without data loss.
- Fixed codes reach the same generated dungeon.
- The challenge rules appear before play.

Verification: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

### enemy-telegraphs

Status: planned.

User-visible outcome: One enemy attack pattern becomes readable before damage arrives.

Bounded deliverable: Add windup, attack, and recovery states with matching visual feedback.

Acceptance criteria:

- State timing is deterministic.
- Damage occurs only during the attack window.
- Headless tests cover the timing and damage window.

Verification: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## Scope rules

- Keep generation deterministic.
- Keep every exit reachable.
- Add tests for new behavior.
- Record user-facing changes in the changelog.
