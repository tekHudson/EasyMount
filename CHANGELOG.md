# Changelog

All notable changes to EasyMount are documented here.
This project follows [Keep a Changelog](https://keepachangelog.com) and
[Semantic Versioning](https://semver.org).

## [Unreleased]

## [1.1.1] - 2026-09-17
### Changed
- CI: release zips are no longer suffixed with the packager's automatic
  game-flavor label (e.g. `-classic`).

## [1.1.0] - 2026-08-09
### Added
- Warlock: drop Demon Form automatically so the mount keybind works on the
  first press instead of erroring for being shapeshifted (previously only
  handled if HoneyLock happened to also be loaded). Toggle in options.

## [1.0.0] - 2026-07-31
### Fixed
- Removed the visible 32x32 draggable mount-button icon; the secure button
  is now invisible (no textures) and works purely as a keybind target.
### Verified
- Confirmed working in-game.

## [0.0.1] - 2026-07-31
### Added
- Initial build: one keybind that scans your bags (item-based mounts) and
  spellbook (Paladin/Warlock mount spells) and casts the fastest mount you
  currently carry, clamped to your actual Riding skill.
- Full Classic Era / Season of Discovery mount database (item + spell IDs).
- Minimap icon and options panel to enable/disable individual mounts.
