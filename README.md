<p align="center">
  <img src="docs/banner.png" alt="Azeroth Signature: your signature in Azeroth" width="100%">
</p>

<h1 align="center">Azeroth Signature</h1>
<h3 align="center">Your signature in Azeroth.</h3>

<p align="center">
  <a href="https://www.curseforge.com/wow/addons/azeroth-signature"><b>Download on CurseForge</b></a> ·
  <a href="../../releases/latest">GitHub Releases</a> ·
  <a href="../../issues/new/choose">Report a bug</a>
</p>

<p align="center">
  <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-gold">
  <img alt="Retail" src="https://img.shields.io/badge/Retail-12.1.5-blueviolet">
  <img alt="Forever" src="https://img.shields.io/badge/Forever-1.60.1-blue">
  <img alt="No dependencies" src="https://img.shields.io/badge/dependencies-none-success">
    <img alt="Vibecoded" src="https://img.shields.io/badge/vibecoded-claude-orange?logo=claude&logoColor=orange">
</p>

---

Make your mark on every message.

**Azeroth Signature** automatically adds a signature of your choice to the chat messages you send, so everyone knows who's talking, whether that's `<MyMain>` on your alt, `(( OOC ))` for out-of-character chatter, or anything else you can think of. Set it once, pick the channels, and forget about it.

## Why you'll like it

- **Set it and forget it.** Type your message as usual; the signature is added for you when you press Enter.
- **You pick where it shows.** Say, Yell, Party, Raid, Instance, Guild, Officer, Whisper and custom channels, each one a checkbox.
- **Not on every character.** Add the characters that should stay unsigned and Azeroth Signature leaves them alone.
- **Plays nice with commands.** Slash commands like `/dance` or `/roll` are never touched, and a message is never signed twice.
- **Clean, native settings.** A single options panel with a live preview, right inside the game's own settings.
- **Tiny and standalone.** One small addon, no dependencies, nothing running in the background.

## Ideas for your signature

Anything up to 100 characters works. A few favourites:

| Signature | Great for |
|---|---|
| `<MyMain>` | Letting people know who's behind your alt |
| `(( OOC ))` | Marking out-of-character messages while roleplaying |
| `[Tank]` | Announcing your role in groups |
| `~` | A subtle personal mark |

## Features

### Signature

- Choose any custom prefix; a space is added automatically between it and your message
- Turn the whole thing on or off with one checkbox
- **Live preview** in the options, so you see exactly how a message will look: `<MyMain> Hello, Azeroth!`

### Channels

Tick the channels that should carry your signature (all are ticked by default):

> Say · Yell · Party · Raid · Instance Chat · Guild · Officer · Whisper · Custom channels (`/1`, `/2`, …)

**All** and **None** buttons make it quick. If **Raid** is ticked, messages sent to **Instance Chat** are signed as well, because WoW reports `/raid` in an instance group as Instance Chat.

### Excluded characters

Enter character names separated by commas (e.g. `AltCharacter, Mage123, MyWarrior`). Names are not case-sensitive. The **Add current** button adds the character you're playing right now.

### Smart rules

| Situation | What happens |
|---|---|
| You type a slash command (`/dance`, `/roll`, …) | Not signed |
| The message already starts with your signature | Not signed again |
| You're in combat | Not signed (chat text isn't modified during combat, in line with Retail's restrictions) |
| The character is on your exclusion list | Not signed |
| The channel isn't ticked | Not signed |

## Installation

**CurseForge app / site** (recommended): search for **Azeroth Signature** and install, or [download it here](https://www.curseforge.com/wow/addons/azeroth-signature).

**Manually:**

1. Download the latest zip from [GitHub Releases](../../releases/latest).
2. Extract the `AzerothSignature` folder.
3. Copy it into the `Interface/AddOns/` folder of your game version.
4. Restart the game or type `/reload`.
5. Open **Options → AddOns → Azeroth Signature**, or type `/azsig`.

## Quick start

1. Type **`/azsig`** to open the settings.
2. **Change the default signature.** Out of the box it's `<MyMain>`, so set your own before you chat.
3. Tick the channels you want and, if needed, list the characters to exclude.
4. Click **Save Settings**. The changes only take effect once you've saved them.
5. Chat as usual. Your signature appears at the start of your messages.

> **Reset to defaults** loads the default values into the panel, but nothing changes until you click **Save Settings**.

## Commands

| Command | What it does |
|---|---|
| `/azsig` | Open the Azeroth Signature settings |

## Compatibility

| Game | Version | Interface |
|---|---|---|
| Retail | 12.0.x | 120000 |
| WoW Forever | tested | 16001 |

Compatibility may vary between client versions. Other Classic versions (Era, Anniversary, Mists of Pandaria Classic) are not officially supported: the addon relies on a chat callback that these clients may not provide, in which case it shows a notice and does nothing.

If WoW flags the addon as out of date after a patch, tick **Load out of date AddOns**, or run `/dump select(4, GetBuildInfo())` and [open an issue](../../issues/new/choose) with the number.

## FAQ

**Why wasn't my message signed?**
Check the list above: it's a slash command, the channel isn't ticked, the character is excluded, you were in combat, or the addon is switched off in the options.

**Does the signature count towards the 255-character message limit?**
Yes. The signature is part of the message, so a long signature leaves less room for your text.

**Where are my settings stored?**
In the addon's saved variables (`AzerothSignatureDB`), which are account-wide. Use the exclusion list for characters that shouldn't sign.

**I upgraded from Name2ChatSafe. Do I lose my settings?**
No. If Name2ChatSafe settings are found, Azeroth Signature imports them automatically (anything you've already set here is kept).

**Can I use an empty signature to turn it off?**
No, an empty signature can't be saved. Untick **Enable automatic signature** instead.

**It doesn't work with my chat addon.**
Azeroth Signature uses the standard chat edit box. Chat addons that replace it may not trigger the signature. If you find one, please [open an issue](../../issues/new/choose) and tell us which.

## Wishlist

Ideas, not promises. Open an issue if one matters to you:

- Different signatures per channel or per character
- Signature at the end of the message instead of the start
- Quick on/off command (`/azsig on`, `/azsig off`)
- Variables in the signature (character name, class, …)

## Contributing

Bug reports and ideas are welcome via [Issues](../../issues/new/choose). Pull requests too: the whole addon is a single readable Lua file.

When reporting a bug, please include your game version (Retail / WoW Forever), the addon version, and any Lua error text (BugSack or the in-game error popup).

## License

Released under the [MIT License](LICENSE). The logo and banner artwork were created for this project and are covered by the same license.
