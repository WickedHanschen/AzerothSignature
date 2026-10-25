# Changelog

All notable changes to **Azeroth Signature** are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [1.2.0] - 2026-10-23

First public release. Put your name on every word.

### Added
- **Automatic signature**: a custom prefix is added to your outgoing chat messages when you press Enter, with a space inserted for you.
- **Channel selection**: Say, Yell, Party, Raid, Instance Chat, Guild, Officer, Whisper and custom channels (`/1`, `/2`, …), with **All** and **None** buttons. Raid also covers Instance Chat, since WoW reports `/raid` in an instance group as Instance Chat.
- **Excluded characters**: a comma-separated, case-insensitive list, plus an **Add current** button.
- **Options panel** under *Options → AddOns → Azeroth Signature*, with an enable switch, a signature field (up to 100 characters), a live preview, **Save Settings**, **Reset to defaults** and on-screen status messages.
- **`/azsig`** slash command to open the settings.
- **Smart rules**: slash commands are never signed, a message is never signed twice, and nothing is modified during combat.
- **Automatic import** of settings from the earlier Name2ChatSafe addon, when present.
- Support for **Retail 12.0** (Interface 120000) and **WoW Forever** (Interface 16001).
