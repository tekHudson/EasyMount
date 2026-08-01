# EasyMount

One keybind. No macros, no bag digging — EasyMount scans your bags and
spellbook and summons the **fastest mount you actually have**.

Pure Lua (no XML except `Bindings.xml`), no Ace3, single code path for the
Classic Era / Season of Discovery client.

## Why

In Classic, mounts are bag items you right-click (except Paladins and
Warlocks, who get self-cast mount spells). Most players only ever carry one
mount at a time, but which one changes — starter mount at 40, upgraded at 60,
a rep/rare-drop mount later. EasyMount keeps a live picture of which mounts
you're currently carrying and always fires the fastest one your Riding skill
can actually use, on one key.

## Design

- **No XML** except `Bindings.xml`. A single, invisible `SecureActionButtonTemplate`
  drives the keybind (no textures, so nothing renders on screen); macro text
  handles dismount vs. summon so it works in combat lockdown.
- **No Ace3 / minimal libs.** `LibStub` + `LibDataBroker-1.1` + `LibDBIcon-1.0`
  for the minimap icon only.
- **Rescans on `BAG_UPDATE`** (debounced) and riding-skill change, not on
  every keypress — the active-mount list is cached in memory and only
  recomputed when your inventory or skill actually changes.
- Speed is clamped by your real Riding skill: owning a 100%-speed mount at
  Journeyman riding still only gets you 60%, so EasyMount won't pick it over
  a mount you can actually ride at full speed.

## Usage

- Bind **EasyMount: Summon fastest mount** in Key Bindings.
- `/em` — open options
- `/em list` — debug dump of currently detected mounts and the one that would
  be cast

## Layout

```
EasyMount.lua      bootstrap: namespace, event dispatch, defaults, slash command
Data\Mounts.lua    Classic Era / SoD mount database (item + spell IDs)
Core\Scan.lua      bag + spellbook scan -> EM.activeMounts, debounced rescans
Core\Mount.lua     fastest-mount selection + secure button/macro
UI\Options.lua     minimap icon + enable/disable panel
Bindings.xml       keybind hook
```

## Status

v1.0.0 — verified working in-game. Classic Era / Season of Discovery only.
TBC Anniversary support may follow
later.
