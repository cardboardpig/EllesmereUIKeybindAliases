<img src="docs/assets/icon.png" alt="Keybind Aliases for EllesmereUI icon" width="128" height="128">

# Keybind Aliases for EllesmereUI

A small World of Warcraft Retail and WoW Forever addon that adds custom keybind labels to EllesmereUI action bars. Aliases change the displayed text only; your actual key bindings stay the same.

An unofficial companion addon for EllesmereUI. Not affiliated with or endorsed by the EllesmereUI team.

The settings editor lives under **Paper Bacon Bits → Keybind Aliases** in EllesmereUI. The section is shared with Shortest Path Forever when both companion addons are installed. Either addon works on its own.

## Requirements

- World of Warcraft Retail (TOC interface version `120100`) or WoW Forever (`16001`).
- `EllesmereUI` with Plugin API v1 or later and `EllesmereUIActionBars` installed and enabled.

WoW Forever's interface ID matches the [upstream EllesmereUI Action Bars TOC](https://github.com/EllesmereGaming/EllesmereUI/blob/main/EllesmereUIActionBars/EllesmereUIActionBars.toc). Both clients use the same alias and options code.

## Installation

Download and install [Keybind Aliases for EllesmereUI on CurseForge](https://www.curseforge.com/wow/addons/keybind-aliases-for-ellesmereui).

## Usage

Run `/euika`, or open EllesmereUI options and select **Paper Bacon Bits → Keybind Aliases**. Click **+ Add Replacement**, enter the exact shortened label currently shown on your action bar under **CURRENT EUI TEXT**, and enter your preferred label under **DISPLAY AS**. Press Enter or click away to apply.

- Matching is exact and case-sensitive.
- A blank replacement hides the matching label.
- If multiple entries have the same source label, the last entry wins.
- **Remove** deletes one alias. **Clear All** removes every alias.
- Aliases are account-wide and persist across interface reloads.

## Repository layout

The repository root doubles as the installed addon folder, so there is no extra nested addon directory.

```text
EllesmereUIKeybindAliases/
├── EllesmereUIKeybindAliases.toc
├── Runtime.lua                 # Saved aliases and action-bar text hooks
├── SettingsGroup.lua           # Shared Paper Bacon Bits settings registration
├── OptionsIntegration.lua      # EllesmereUI options page
├── Media/
│   └── Icon.tga                # In-game 256 × 256, 32-bit TGA
├── docs/
│   └── assets/                # README icon and addon screenshot
├── scripts/
│   └── package.ps1             # Builds an installable addon ZIP
└── README.md
```

## Packaging

Run `./scripts/package.ps1` in PowerShell. It creates `dist/EllesmereUIKeybindAliases-<version>.zip` using the version in the TOC. The archive contains the addon folder, its Lua files, TOC, in-game icon, and license.

The default square icon and the ready-made WoW texture come from the supplied `EllesmereUIKeybindAliases_IconPack.zip`; the artwork is used unchanged.

Settings use the [EllesmereUI Plugin API](https://github.com/EllesmereGaming/EllesmereUI/blob/main/PLUGINS_API.md). The addon does not modify EUI's modules or read its private fields. Existing saved aliases are retained when upgrading. Aliases remain separate from EUI profiles and overrides.

Reviewed against Plugin API v3 on 3 November 2026 (API documentation last updated in EllesmereUI v9.6.5 on 23 October 2026). The v2 cooldown-icon lookup and v3 cooldown-layout repopulation APIs are not needed by this addon; its settings integration continues to use the compatible v1 API.

EllesmereUI search indexes the **Keybind Aliases** page. Runtime label discovery uses named action-bar frames and WoW's frame APIs. Those frame names are not part of the Plugin API, so future action-bar changes may still require a compatibility update.

In-game behavior must be checked in WoW; automated tests and packaging checks do not exercise the live WoW UI.

## Validation

With Lua 5.1 installed, run `lua scripts/test.lua` from the repository root. The mocked WoW/EUI checks cover alias updates and restoration, saved-data retention, shared settings registration across add-on load orders, search pre-build safety, editor callbacks, and page-cache isolation.

After updating in WoW, run `/reload`, then `/euika`. Confirm the plugin section opens without an update popup, and try adding, editing, removing, and clearing aliases on action, pet, and stance bars. Switch away and back to check cached settings, and verify keybind changes still update the displayed labels.

## License

Licensed under the [MIT License](LICENSE). Copyright (c) 2026 cardboardpig.
