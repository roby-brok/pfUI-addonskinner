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
> `MikScrollingBattleTextOptions` addon, whose main window is an untouched 2007 Blizzard-art
> panel — six tabs and well over a hundred buttons, checkboxes, editboxes, dropdowns and
> scrollbars, built from `UI-Character-General` tiles.
>
> **Only `MSBTFrameOptions` is skinned.** Its three secondary windows are not, and cannot
> safely be: `MSBTFontSettingsFrame` is declared 350×270, `MSBTTriggerConfigFrame` 400×270
> and `MSBTScrollAreaMoverControlFrame` 180×500, all far smaller than the content they show.
> They relied on Blizzard art overflowing the frame rect to look like windows at all, so
> stripping it leaves the backdrop covering only the true rect and the widgets spilling onto
> the game world. Making those work means resizing and re-anchoring someone else's layout,
> which is a different job from skinning it. `MSBTFrameOptions` is 640×440 and honestly
> sized, so that is the one that gets skinned.
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
>
> Two things worth knowing if you write a skin for a window like this one:
>
> - **Anchor tab-name patterns to the end of the string.** The six tabs are
>   `MSBTFrameOptionsTab1`…`Tab6`, but every widget *inside* a tab is named through it —
>   `MSBTFrameOptionsTab3FrameEvent1EditFontSettingsButton` — so an unanchored `Tab%d`
>   matches all of them and quietly routes every button in the window through `SkinTab`
>   instead of `SkinButton`.
> - **Use the legacy backdrop on `toplevel` frames.** `CreateBackdrop`'s default path
>   parents the backdrop to the window at frame level − 1, which on a toplevel frame lands
>   *behind* the window; the body then renders fully transparent with the game world showing
>   through. Passing `legacy = true` paints the frame itself instead.
> - **`SkinScrollbar` takes the scrollbar, not the scroll frame** — `$parentScrollBar`. The
>   mistake is silent and expensive: the skinner wraps each skin in a single `pcall`, so one
>   bad call abandons everything after it. Here that produced a window whose first tab was
>   flawless and whose other five were completely untouched, with no error shown unless you
>   enable notifications. Wrapping each individual widget in its own `pcall` means one odd
>   widget costs you that widget instead of the other hundred and fifty.

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
