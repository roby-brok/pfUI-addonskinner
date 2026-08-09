> ### About this fork
>
> A fork of [jrc13245/pfUI-addonskinner](https://github.com/jrc13245/pfUI-addonskinner),
> maintained for [OctoWoW](https://octowow.st) by **Roby_Brok**. All credit for the addon
> goes to [dein0s](https://gitlab.com/dein0s_wow_vanilla/pfUI-addonskinner),
> [RoadBlock](https://github.com/Road-block/) and jrc13245. The upstream README invites
> forks and pull requests for new skins, so that is what this is — use the original unless
> you specifically want what is below.
>
> **0.5 — new skin: Mik's Scrolling Battle Text.** MSBT itself is scrolling text drawn on
> the WorldFrame and has nothing to skin; its configuration lives in the load-on-demand
> `MikScrollingBattleTextOptions` addon, which is an untouched 2007 Blizzard-art window —
> four top-level frames built from `UI-Character-General` tiles, six tabs, and well over a
> hundred buttons, checkboxes, editboxes, dropdowns and scrollbars.
>
> The skin is registered under the *options* addon's folder name, so `ADDON_LOADED` applies
> it the moment the window is first opened rather than at login, when none of those frames
> exist yet. Rather than enumerating names — the event and trigger rows alone are generated
> from templates in the hundreds — it walks the frame tree and skins by object type, marking
> each widget so reopening the window is a no-op, and re-walks on show to catch rows that
> are created lazily.
>
> Two deliberate exclusions: colour swatches (the swatch *is* its texture, so skinning it
> would hide the colour it exists to show) and the three scroll-area mover frames (drag
> handles whose art is the affordance).

This addon is an external module for [pfUI](https://github.com/shagu/pfUI) addon.

## Screenshots
![settings](settings.png)


## Description
Addon provides you with pfUI-themed skins for other addons. It also allowse you to create and load your own skins.

You can check some code in `skins` folder to get the idea of how it is done and go on from there with your own skins and ideas.
Do not forget to add your skins to `pfUI-addonskinner.toc` file.

If you want a skin for an addon not shown, fork my repo and make the skin! open a PR and i will add it to this repo!

## Installation
**This addon will not function without [pfUI](https://github.com/shagu/pfUI) installed**
1. Download **[Latest Version](https://github.com/mrrosh/pfUI-addonskinner/archive/refs/heads/master.zip)**
2. Unpack the Zip file
3. Rename the folder to "pfUI-addonskinner"
4. Copy "pfUI-addonskinner" into Wow-Directory\Interface\AddOns
5. Restart WoW


## Credits
[dein0s](https://gitlab.com/dein0s_wow_vanilla/pfUI-addonskinner)
[RoadBlock](https://github.com/Road-block/)
