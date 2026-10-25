# Changelog

All notable changes to **Azeroth Signature** are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.2] - 2026-10-25

### Changed
- Updated for Retail patch 12.1.5, so the addon is no longer flagged as out of date.
- Messages that would go over the chat length limit once signed are now sent unsigned, instead of losing their last words.

### Fixed
- Settings from Name2ChatSafe are now imported reliably. Previously Azeroth Signature could load before Name2ChatSafe and miss its settings.

## [1.2.1] - 2026-10-25

### Changed
- No changes to how the addon works. This release is the first one published through the new automated release process.
- The version number shown in the AddOns list now follows the release tag.

## [1.2] - 2026-10-23

### Added
- `/azsig` slash command to open the settings.
- Redesigned options panel, with a live preview of your signature.
- Add current, All and None buttons, and a Reset to defaults button, with on-screen status messages.

### Changed
- Slash commands (such as `/dance` or `/roll`) are never signed.

## [1.0.2] - 2026-10-16

### Added
- Ticking **Raid** now also signs messages sent to **Instance Chat**, since WoW reports `/raid` in an instance group as Instance Chat.

### Changed
- Shorter label for custom channels: "Custom channels (/1, /2...)".
- Internal clean-up of the signing, exclusion and settings-migration code.

### Fixed
- Addon messages no longer fail if the text isn't a plain string.

## [1.0.1] - 2026-10-11

### Added
- Support for **WoW Forever** (Interface 16001).

## [1.0.0] - 2026-10-11

### Added
- Automatic signature added to your outgoing chat messages.
- Choose which channels are signed: Say, Yell, Party, Raid, Instance Chat, Guild, Officer, Whisper and custom channels.
- Excluded characters list, with comma-separated names.
- Options panel under *Options → AddOns → Azeroth Signature*.
- Messages are never signed twice, and nothing is modified during combat.
- Automatic import of settings from the earlier Name2ChatSafe addon.
- Support for **Retail** (Interface 120000).
