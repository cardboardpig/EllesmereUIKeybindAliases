<img src="docs/assets/icon.png" alt="EllesmereUI Keybind Aliases icon" width="128" height="128">

# EllesmereUI Keybind Aliases

A small World of Warcraft Retail addon that adds custom keybind labels to EllesmereUI action bars. Aliases change the displayed text only; your actual key bindings stay the same.

## Requirements

- World of Warcraft Retail (TOC interface version `120100`).
- `EllesmereUI` and `EllesmereUIActionBars` installed and enabled.

## Installation

Download this repository using **Code → Download ZIP**, extract it, and rename the extracted folder to `EllesmereUIKeybindAliases`. Place that folder inside:

```text
World of Warcraft/_retail_/Interface/AddOns/
```

The resulting path must be `AddOns/EllesmereUIKeybindAliases/EllesmereUIKeybindAliases.toc`. Restart WoW or reload the interface after updating the addon.

## Usage

Open EllesmereUI options and select **Action Bars → Keybind Aliases**. Click **+ Add Replacement**, enter the exact shortened label currently shown on your action bar under **CURRENT EUI TEXT**, and enter your preferred label under **DISPLAY AS**. Press Enter or click away to apply.

- Matching is exact and case-sensitive.
- A blank replacement hides the matching label.
- If multiple entries have the same source label, the last entry wins.
- **Remove** deletes one alias; **Clear All** removes every alias.
- Aliases are account-wide and persist across interface reloads.

## Repository layout

The repository root doubles as the installed addon folder, so there is no extra nested addon directory.

```text
EllesmereUIKeybindAliases/
├── EllesmereUIKeybindAliases.toc
├── Runtime.lua                 # Saved aliases and action-bar text hooks
├── OptionsIntegration.lua      # EllesmereUI options page
├── Media/
│   └── Icon.tga                # In-game 256 × 256, 32-bit TGA
├── docs/
│   └── assets/icon.png         # Matching default icon for this README
├── scripts/
│   └── package.ps1             # Builds an installable addon ZIP
└── README.md
```

## Packaging

Run `./scripts/package.ps1` in PowerShell. It creates `dist/EllesmereUIKeybindAliases-2.5.0.zip` containing the addon folder, its Lua files, TOC, and in-game icon. Repository documentation and development files are excluded.

The default square icon and the ready-made WoW texture come from the supplied `EllesmereUIKeybindAliases_IconPack.zip`; the artwork is used unchanged.

This addon depends on EllesmereUI internals, so changes to EllesmereUI may require compatibility updates. In-game behavior must be checked in WoW; packaging checks do not exercise the WoW UI.
