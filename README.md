# Azeroth Signature

Automatically sign your chat messages with a custom prefix, such as `<MyMain>`, so people always know who is behind your alts. Choose which channels get the signature and which characters are left out.

**Current version:** 1.2 | **Game version:** World of Warcraft Retail & Forever

---

## Features

- **Automatic signature** added in front of your messages as you send them.
- **Per-channel control** for Say, Yell, Party, Raid, Instance Chat, Guild, Officer, Whisper and custom channels (`/1`, `/2`...).
- **Excluded characters**: list the characters that should never use the signature.
- **Live preview** of your signature while you type it.
- **Modern options panel** with a clean card-based layout, quick **All** / **None** channel buttons, and an **Add current** button for the exclusion list.
- **Safe by design**: the signature is never applied during combat, and slash commands (e.g. `/dance`, `/roll`) are left untouched.
- **Settings migration** from the legacy `Name2ChatSafeDB` is automatic.

---

## Installation

1. Download the latest release.
2. Extract the `AzerothSignature` folder into:
   `World of Warcraft/_retail_/Interface/AddOns/`
3. Restart the game or type `/reload`.

---

## Usage

Open the options from **Game Menu > Options > AddOns > Azeroth Signature**, or type:

```
/azsig
```

| Setting | Description |
| --- | --- |
| **Enable automatic signature** | Turns the signature on or off. |
| **Signature / prefix** | The text added before each message. A trailing space is added automatically. |
| **Excluded characters** | Comma-separated names that will never use the signature. Example: `AltCharacter, Mage123, MyWarrior` |
| **Channels** | Pick the channels where the signature is applied. |

Click **Save Settings** to apply your changes. **Reset to defaults** restores the default values in the panel, and they take effect after you save.

---

## Notes

- The signature is not applied while you are in combat, in line with Retail chat restrictions.
- Messages that already start with your signature are not signed twice.
- Raid chat inside an instance group is covered by the **Raid** option.
- Settings are stored in the `AzerothSignatureDB` saved variable.

---

## Feedback and support

Found a bug or have a suggestion? Open an issue on GitHub or leave a comment on the CurseForge page. Please include your game version and a description of the problem.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full version history.
