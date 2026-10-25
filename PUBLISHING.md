# Publishing checklist

This file is for you (the maintainer). It's excluded from the packaged addon by `.pkgmeta`.

## 0. Before anything else: test in game

The addon files in this repo are exactly the ones you supplied; nothing in the code was changed. The README states that it was tested on WoW Forever. Before the first public release, run through this on every version you can, especially Retail:

- [ ] Addon loads without a Lua error (`/console scriptErrors 1`)
- [ ] `/azsig` and *Options → AddOns → Azeroth Signature* both open the panel
- [ ] Set a signature, click **Save Settings**, `/reload`, and check it persisted
- [ ] A message in **Say** is signed; a slash command (`/dance`) is not
- [ ] A message that already starts with the signature isn't signed twice
- [ ] Untick a channel: messages there are no longer signed
- [ ] Add your character to **Excluded characters** (try **Add current**): no signature
- [ ] **Raid** ticked + a message in **Instance Chat** is signed
- [ ] **Whisper** and a custom channel (`/1`) behave as expected
- [ ] In combat: messages go out unsigned
- [ ] **Reset to defaults** fills the panel, and nothing changes until **Save Settings**
- [ ] (Optional) Migration: with a `Name2ChatSafeDB` present, settings are imported

## 1. Replace the placeholders

| Placeholder | Where | Replace with |
|---|---|---|
| `YOUR_GITHUB_USER` | `docs/curseforge-description.*` | Your GitHub username |
| `https://www.curseforge.com/wow/addons/azeroth-signature` | `README.md` | The real URL once the CurseForge project exists |
| `AzerothSignature` (repo name) | `docs/curseforge-description.*` | Your actual repository name, if different |

```bash
grep -rn "YOUR_GITHUB_USER" .
```

## 2. Take screenshots

Save these in `docs/screenshots/` and add a *Screenshots* section to `README.md`:

1. `options.png`: the full options panel (signature, exclusions, channels)
2. `chat.png`: a signed message in the chat window
3. `preview.png`: close-up of the live preview (optional)

Upload the same shots in the CurseForge *Images* tab.

## 3. GitHub

1. Create the repository and push this folder to it.
2. *Settings → General → Social preview:* upload `docs/social-preview.png` (1280×640).
3. Add topics: `warcraft`, `wow-addon`, `chat`, `lua`, `world-of-warcraft`.

## 4. CurseForge project

Create the project at <https://authors.curseforge.com/> with:

| Field | Value |
|---|---|
| Game | World of Warcraft, *Addons* |
| Name | Azeroth Signature |
| Main category | Chat & Communication (you can add Roleplay as an extra) |
| License | MIT |
| Logo | `docs/logo.png` (512×512) |
| Summary (max 250 chars) | See below |
| Description | Paste `docs/curseforge-description.html` (use the editor's source/HTML mode) or the `.md` version |
| Source / Issues URL | Your GitHub repo and its `/issues` page |

**Summary:**

> Your signature in Azeroth. Automatically add a custom prefix to your chat messages, choose which channels use it, exclude specific characters, and manage it all from a clean in-game options panel. Retail and WoW Forever.

After the project is created, add its numeric **Project ID** to `AzerothSignature.toc`:

```
## X-Curse-Project-ID: 123456
```

## 5. Automatic releases (GitHub Actions)

The workflow in `.github/workflows/release.yml` uses the [BigWigs packager](https://github.com/BigWigsMods/packager). On every tag starting with `v` it builds the zip, attaches it to a GitHub Release and uploads it to CurseForge.

1. On CurseForge, create an API token (*Account → API Tokens*).
2. In GitHub, go to *Settings → Secrets and variables → Actions* and add the secret **`CF_API_KEY`**.
3. Optional, for Wago.io: add **`WAGO_API_TOKEN`** and put `## X-Wago-ID: <id>` in the `.toc`.

## 6. Cutting a release

1. Update `CHANGELOG.md` (new `## [x.y.z] - date` section on top) and the `## Version:` line in the `.toc`.
2. If a new WoW patch shipped, update the `## Interface:` line.
3. Commit, then tag and push:

```bash
git tag v1.2.0
git push origin main --tags
```

The packager publishes the release notes from `CHANGELOG.md` and reads the supported game versions from the `## Interface:` line.

> Tip: if you'd rather not edit the version by hand every time, change the `.toc` line to `## Version: @project-version@`. Packaged releases will then take the version from the tag. In a plain git checkout the AddOns list shows the literal text instead.

## Notes on version numbers

- Your `.toc` says `1.2`; the changelog and tag use `1.2.0` (Semantic Versioning). Use whichever you prefer, as long as they match.
- The `## Interface:` line currently lists `120000` (Retail 12.0) and `16001` (WoW Forever). Add new numbers to it after patches; old ones can stay. You can read the current number in game with `/dump select(4, GetBuildInfo())`.
